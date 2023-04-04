FROM node:16.14.2-slim AS base

# install dependencies only when needed
FROM base AS dependencies

# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat

WORKDIR /app

COPY package.json pnpm-lock.yaml* pnpm-workspace.yaml ./

RUN corepack enable
RUN pnpm --filter=explore-education-statistics-frontend... install
RUN pnpm --filter=explore-education-statistics-frontend build

# 2. rebuild source code only when needed
FROM base AS builder

WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY . .

# 3. production image, copy all the files and start frontend
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/package.json . 
COPY --from=builder /app/pnpm-lock.yaml .
COPY --from=builder /app/pnpm-workspace.yaml .
COPY --from=builder /app/src/explore-education-statistics-common/ ./src/explore-education-statistics-common/
COPY --from=builder /app/src/explore-education-statistics-frontend/ ./src/explore-education-statistics-frontend/

USER node 
EXPOSE 3000
ENV PORT 3000

CMD ["pnpm", "start"]