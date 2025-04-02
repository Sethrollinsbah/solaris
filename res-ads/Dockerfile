# Base Bun image
FROM oven/bun:1-alpine AS base
WORKDIR /app

# Dependencies stage
FROM base AS deps
# Copy package.json (and lock file if it exists)
COPY package.json ./
# Using wildcards to handle both bun.lock and bun.lockb (or none)
COPY bun.lock* ./
# Install dependencies
RUN bun install

# Builder stage
FROM base AS builder
# Copy node_modules from deps
COPY --from=deps /app/node_modules ./node_modules
# Copy all other files
COPY . .
# Set production environment for build
ENV NODE_ENV=production
# Build the application
RUN bun run build

# Production stage
FROM base AS production
WORKDIR /app

# Set environment
ENV NODE_ENV=production
ENV PORT=3000

# Copy built files and package.json
# Adjust this path to match the actual build output directory
COPY --from=builder /app/.svelte-kit/cloudflare ./build
# Or try one of these alternatives if the above doesn't work:
# COPY --from=builder /app/build ./build
# COPY --from=builder /app/.svelte-kit/build ./build

COPY package.json ./
# Copy lock file with wildcard to handle different possibilities
COPY bun.lock* ./

# Install only production dependencies
RUN bun install --production

# Expose port
EXPOSE ${PORT}

# Run the app
CMD ["bun", "run", "build/index.js"]
