# Using base image node.js
FROM node:18-alpine 

# Setting the Working directory
WORKDIR /app

#Copying the package.json and yarn.lock to the WORKDIR
COPY package.json yarn.lock ./

# Installing the dependencies
RUN yarn install




# Copying app to the container
COPY . .

RUN yarn build

#Exposing the port our localhost will be on 
EXPOSE 3000

# Starting the application
CMD [ "yarn", "start" ]




