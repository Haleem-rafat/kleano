FROM node:20-bullseye-slim As build

WORKDIR /usr/src/app

COPY --chown=node:node ./package*.json .

RUN npm i

COPY --chown=node:node . .

RUN npm run build && npm i --omit=dev

USER node


FROM node:slim As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist
COPY --chown=node:node --from=build /usr/src/app/.env .

EXPOSE 3000

CMD [ "node", "dist/main.js" ]