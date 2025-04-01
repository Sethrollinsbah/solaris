# ---- Base Bun ----
# Use the official Bun image from Oven. Alpine is smaller.
# Choose a specific version tag if needed, e.g., oven/bun:1.0.30-alpine
FROM oven/bun:1-alpine AS base
WORKDIR /app

# ---- Dependencies ----
# Install dependencies first using bun to leverage Docker cache
FROM base AS deps
# Copy package manifest and bun's lockfile
# SvelteKit often still needs package.json for scripts/metadata
COPY package.json bun.lockb ./
# Use --frozen-lockfile for deterministic installs matching the lockfile
RUN bun install --frozen-lockfile

# ---- Builder ----
# Build the SvelteKit application using bun
FROM base AS builder
# Copy installed dependencies from the 'deps' stage
COPY --from=deps /app/node_modules ./node_modules
# Copy the rest of the application source code
COPY . .
# Set NODE_ENV to production for the build process if needed by any build scripts
# ENV NODE_ENV=production
# Run the build script defined in package.json using bun
RUN bun run build

# ---- Production ----
# Final, minimal image using bun runtime
FROM base AS production
WORKDIR /app

# Set environment to production for runtime optimizations
ENV NODE_ENV=production
# Set the default port the app runs on (change if needed)
ENV PORT=3000

# Copy only necessary production artifacts
# Copy the built application output (from adapter-node)
COPY --from=builder /app/build ./build
# Copy package.json and lockfile needed to install *production* dependencies
COPY package.json bun.lockb ./

# Install *only* production dependencies using bun
# This ensures the final image doesn't contain devDependencies
RUN bun install --production --frozen-lockfile

# Expose the port the app runs on
EXPOSE ${PORT}

# Command to run the application using bun
# adapter-node produces a build/index.js entrypoint that bun can run
CMD ["bun", "run", "build/index.js"]

# ---- Development (Optional) ----
# Example development stage using bun
# FROM deps AS dev
# COPY . .
# EXPOSE 5173 # Default SvelteKit dev port
# ENTRYPOINT [ "bun", "run", "dev", "--host" ]
