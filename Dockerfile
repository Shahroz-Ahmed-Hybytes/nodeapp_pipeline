# Use an official Node.js runtime as the base image
#FROM node:14

# Set the working directory inside the container
#WORKDIR /app

# Copy package.json and package-lock.json to the working directory
#COPY package*.json ./

# Install application dependencies
#RUN npm install

# Copy the rest of your application code to the container
#COPY . .

# Expose the port your application listens on (if necessary)
# Replace with the actual port your Node.js app listens on
#EXPOSE 3001

# Define the command to start your Node.js application
#CMD ["node", "app.js"]

#END
#Start new

FROM node:16 as development

WORKDIR /usr/src/app

# Copy the package.json and package-lock.json files over
# We do this FIRST so that we don't copy the huge node_modules folder over from our local machine
# The node_modules can contain machine-specific libraries, so it should be created by the machine that's actually running the code
COPY package*.json ./

# Now we run NPM install, which includes dev dependencies
RUN npm install

# Copy the rest of our source code over to the image
COPY ./src ./src

EXPOSE 3001

# Run our start:dev command, which uses nodemon to watch for changes
CMD [ "npm", "run", "start:dev" ]

# "Builder" stage extends from the "development" stage but does an NPM clean install with only production dependencies 
FROM development as builder
WORKDIR /usr/src/app
RUN rm -rf node_modules
RUN npm ci --only=production
EXPOSE 3001
CMD [ "npm", "start" ]
 
# Final stage uses a very small image and copies the built assets across from the "builder" stage
FROM alpine:latest as production
RUN apk --no-cache add nodejs ca-certificates
WORKDIR /root/
COPY --from=builder /usr/src/app ./
CMD [ "node", "app.js" ]