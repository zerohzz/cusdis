FROM node:16-alpine3.15 as builder

ARG DB_TYPE=postgresql
ENV DB_TYPE=$DB_TYPE

RUN apk add --no-cache python3 py3-pip make gcc g++

COPY . /app

COPY package.json yarn.lock /app/

WORKDIR /app

RUN npm install -g pnpm
RUN yarn install
RUN npm run build:without-migrate

FROM node:16-alpine3.15 as runner

ENV NODE_ENV=production
ARG DB_TYPE=postgresql
ENV DB_TYPE=$DB_TYPE

WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY . /app

EXPOSE 3000

CMD node_modules/.bin/next start
