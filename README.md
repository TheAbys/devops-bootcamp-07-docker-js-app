## demo app - developing with Docker

This demo app shows a simple user profile app set up using 
- index.html with pure js and css styles
- nodejs backend with express module
- mongodb for data storage

All components are docker-based

### With Docker

#### Before starting to work with a Docker project setup everything

Step 1: Install docker through apt

    sudo apt update

    # download the GNU Privacy Guard file for docker and register it
    sudo apt install ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # add the docker package repository to ubuntu
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update

    # installing docker    
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # testing if installation worked
    sudo docker run hello-world

    # error: hello-world image was not existing locally and downloading it was not possible
    # solution: adding the company proxy to docker following the guide https://docs.docker.com/network/proxy/
    # docker is now usable and working as expected

Step 2: Learning about the features of docker

    docker run <image-name> is a combination of docker pull <image-name> (if it doesn't exist locally) and docker start <image-name>
    docker run <image-name without any additional parameters start a new container in the current terminal blocking it
        stopping it through CTRL+C does not delete the container itself, rerunning the command results in another container creation
        reusing the container is possible through using its container id OR by passing the parameter --name=<container-name> and afterwards running through docker start <container-name> or docker start <container-id>
        using the parameter -d for detach results in not blocking the terminal and keeping the container running in the back
    docker ps lists all currently running containers
        using the parameter -a also lists terminated but existing containers, this can be used to find container id or container name
    docker stop <container-id> or docker stop <container-name> results in terminating the container

    docker run -p 6001:6379 <image-name> can be used to forward the port 6001 of the host system to the port 6379 of the docker container
        while multiple docker containers can use the same port, the host cannot, therefore running multiple containers of a image is possible as long as the host provides different ports

    docker exec -it <image-name> /bin/bash can be used to connect to the bash of a container

#### Starting with the demo project

    docker pull mongo
        pulls the mongo database image from docker hub
    docker pull mongo-express
        pulls the mongo-express graphical web ui for a mongo database from docker hub

    docker network ls
        lists all the existing networks, there are a few by default which will be explained later
    docker network create <network-name>
        will create another bridge network

    docker run -p 27017:27017 -d -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=password --name mongodb --net mongo-network mongo
        basic command to run the mongo db, pass some environment variables (the user information), ports, network and name
    docker run -d \
    -p 27017:27017 \
    -e MONGO_INITDB_ROOT_USERNAME=admin \
    -e MONGO_INITDB_ROOT_PASSWORD=password \
    --name mongodb \
    --net mongo-network \
    mongo
        same command but with intendention to make it more readable 

    docker logs <container-id> to see the logs of a container

    docker run -d \
    -p 8081:8081 \
    -e ME_CONFIG_MONGODB_ADMINUSERNAME=admin \
    -e ME_CONFIG_MONGODB_ADMINPASSWORD=password \
    --name mongo-express \
    --net mongo-network \
    -e ME_CONFIG_MONGODB_SERVER=mongodb \
    mongo-express
        connection works and through localhost:8081 mongo-express is accessable, but the basic auth information is required to access (see docker logs of the container)

    manually create a database "user-account" over the UI (this could also be done through a ENV variable (-e ME_CONFIG_MONGODB_AUTH_DATABASE=user-account)

#### To start the application

Step 1: Create docker network

    docker network create mongo-network 

Step 2: start mongodb 

    docker run -d -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=password --name mongodb --net mongo-network mongo    

Step 3: start mongo-express
    
    docker run -d -p 8081:8081 -e ME_CONFIG_MONGODB_ADMINUSERNAME=admin -e ME_CONFIG_MONGODB_ADMINPASSWORD=password --net mongo-network --name mongo-express -e ME_CONFIG_MONGODB_SERVER=mongodb mongo-express   

_NOTE: creating docker-network in optional. You can start both containers in a default network. In this case, just emit `--net` flag in `docker run` command_

Step 4: open mongo-express from browser

    http://localhost:8081

Step 5: create `user-account` _db_ and `users` _collection_ in mongo-express

Step 6: Start your nodejs application locally - go to `app` directory of project 

    cd app
    npm install 
    node server.js
    
Step 7: Access you nodejs application UI from browser

    http://localhost:3000

### With Docker Compose

#### To start the application

Step 1: start mongodb and mongo-express

    docker-compose -f docker-compose.yaml up
    
_You can access the mongo-express under localhost:8080 from your browser_
    
Step 2: in mongo-express UI - create a new database "user-account"

Step 3: in mongo-express UI - create a new collection "users" in the database "user-account"       
    
Step 4: start node server 

    cd app
    npm install
    node server.js
    
Step 5: access the nodejs application from browser 

    http://localhost:3000

#### To build a docker image from the application

    docker build -t my-app:1.0 .       
    
The dot "." at the end of the command denotes location of the Dockerfile.
