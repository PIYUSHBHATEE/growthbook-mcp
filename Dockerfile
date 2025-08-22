# Use Node.js 20 Alpine as base image for smaller size
FROM node:20-alpine AS base

# Install pnpm globally
RUN npm install -g pnpm@10.6.1

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build stage
FROM base AS build

# Copy source code
COPY . .

# Build the TypeScript project
RUN pnpm run build

# Production stage
FROM node:20-alpine AS production

# Install pnpm globally
RUN npm install -g pnpm@10.6.1

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install only production dependencies
RUN pnpm install --frozen-lockfile --prod

# Copy built application from build stage
COPY --from=build /app/build ./build

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Change ownership of the app directory
RUN chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose port if needed (adjust as necessary)
# EXPOSE 3000

# Set the default command
CMD ["node", "build/index.js"]
