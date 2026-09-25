# SvelteKit + Supabase Starter — Docker image
#
#   docker build -t supabase-starter .
#   docker run -p 5173:5173 supabase-starter
#
# Requires Supabase credentials via environment variables.

FROM node:24-alpine AS builder

WORKDIR /app

# Install dependencies first (layer caching)
COPY package.json package-lock.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

# --- Production stage ---
FROM node:24-alpine

WORKDIR /app

# Copy built app + production dependencies
COPY --from=builder /app/package.json /app/package-lock.json ./
RUN npm ci --omit=dev

COPY --from=builder /app/build ./build

ENV NODE_ENV=production
ENV PORT=5173

EXPOSE 5173

CMD ["node", "build"]
