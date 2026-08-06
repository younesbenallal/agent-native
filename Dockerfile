FROM node:24-slim AS build

WORKDIR /app
RUN corepack enable

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages ./packages
COPY templates/clips/package.json ./templates/clips/package.json
COPY templates/clips/desktop/package.json ./templates/clips/desktop/package.json
COPY templates/clips/chrome-extension/package.json ./templates/clips/chrome-extension/package.json

RUN pnpm install --frozen-lockfile --config.minimumReleaseAge=0

COPY . .
RUN pnpm --filter clips build

FROM node:24-slim AS runtime

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000

COPY --from=build /app/templates/clips/.output .output
RUN mkdir -p /app/data

EXPOSE 3000
CMD ["node", ".output/server/index.mjs"]
