FROM node:16.14.2-alpine AS builder

RUN apk update
RUN adduser -h /home/builder builder

USER builder

WORKDIR /app

COPY --chown=build:build . .

RUN rm -rf src/GovUk.*

RUN corepack enable

RUN pnpm --filter=explore-education-statistics-frontend... install
RUN pnpm --filter=explore-education-statistics-frontend build

FROM node:16.14.2-alpine
RUN adduser -h /home/deployer deployer
USER deployer

ENV NODE_ENV=production

# TOOD LH: 
# * investigate cache mounts (@see https://twitter.com/sidpalas/status/1634194107395641344?s=20)
# * https://snyk.io/blog/10-best-practices-to-containerize-nodejs-web-applications-with-docker/
# * https://snyk.io/blog/10-docker-image-security-best-practices/
# * test whether the non-root users and chown statements that have been added work properly

WORKDIR /usr/src/app

COPY --from=builder /app/package.json .
COPY --from=builder /app/pnpm-lock.yaml .
COPY --from=builder /app/pnpm-workspace.yaml .
COPY --from=builder /app/src/explore-education-statistics-common/ ./src/explore-education-statistics-common/
COPY --from=builder /app/src/explore-education-statistics-frontend/ ./src/explore-education-statistics-frontend/

RUN chown -R deployer:deployer /usr/src/app

RUN corepack enable
RUN pnpm --filter=explore-education-statistics-frontend... --prod install

WORKDIR /usr/src/app/src/explore-education-statistics-frontend

# ENV NODE_ENV=production
EXPOSE 3000

USER node
CMD [ "pnpm", "start" ]