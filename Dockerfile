FROM node:lts

RUN mkdir -p /usr/src/app && \
    chown -R node:node /usr/src/app
WORKDIR /usr/src/app

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

COPY --chown=node:node install/package.json /usr/src/app/package.json

USER node

RUN npm install --only=prod && \
    npm cache clean --force

COPY --chown=node:node . /usr/src/app

ENV NODE_ENV=production \
    daemon=false \
    silent=false

EXPOSE 4567

# make it easier to use with kubernetes
VOLUME /usr/src/app/docker
VOLUME /usr/src/app/public/uploads
# save the config in a volume so the container can be discarded
RUN ln -s /usr/src/app/docker/config.json /usr/src/app/config.json

CMD test -n "${SETUP}" && ./nodebb setup || node ./nodebb build; node ./nodebb start
