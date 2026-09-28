FROM node:24-slim AS build

WORKDIR /app
RUN apt-get update \
  && apt-get install -y --no-install-recommends python3 make g++ \
  && rm -rf /var/lib/apt/lists/* \
  && corepack enable

COPY . .
RUN pnpm install --frozen-lockfile --config.minimumReleaseAge=0
RUN pnpm --filter clips build

FROM node:24-slim AS runtime

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000

COPY --from=build /app/templates/clips/.output .output
RUN corepack enable \
  && pnpm add react@19.2.7 react-dom@19.2.7 yjs@13.6.27 --config.minimumReleaseAge=0
RUN mkdir -p /app/data

EXPOSE 3000
CMD ["node", ".output/server/index.mjs"]
