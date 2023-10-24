# node:20-alpine itself is created on a Dockerfile based on alpine:3.17
FROM node:20-alpine

ENV MONGO_DB_USERNAME=admin \
    MONGO_DB_PWD=password

# RUN gets executed within the container, NEVER on the host
RUN mkdir -p /home/app

# COPY gets executed on the host
COPY ./app /home/app

# set default dir so that next commands executes in /home/app dir
WORKDIR /home/app

# will execute npm install in /home/app because of WORKDIR
# can have multiple RUN commands in a dockerfile
RUN npm install

# no need for /home/app/server.js because of WORKDIR
# why not use RUN? CMD is an entry point command and tells docker that this is what I want to execute
CMD ["node", "server.js"]
