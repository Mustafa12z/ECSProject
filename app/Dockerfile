# #Stage 1: Build Stage

FROM node:18-alpine AS build 

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn install --network-timeout 100000

# #Stage 2: prod

FROM node:18-alpine 

WORKDIR /app

COPY --from=build /app /app 

EXPOSE 3000

CMD ["yarn", "start"]




