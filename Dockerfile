# Build stage
FROM node:20-alpine AS build-stage

# Use Aliyun mirror for Alpine
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# Install pnpm and configure Aliyun npm registry mirror
RUN npm config set registry https://registry.npmmirror.com && \
    npm install -g pnpm && \
    pnpm config set registry https://registry.npmmirror.com

WORKDIR /app

# Copy package descriptors
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Build production assets
RUN pnpm build:prod

# Production stage
FROM nginx:alpine
COPY --from=build-stage /app/dist-prod /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
