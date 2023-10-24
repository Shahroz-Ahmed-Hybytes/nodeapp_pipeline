# Use an official Node.js runtime as the base image
FROM node:14

# Set the working directory inside the container
WORKDIR /nodeapplication

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install application dependencies
RUN npm install

# Copy the rest of your application code to the container
COPY . .

# Expose a port (if your application listens on a specific port)
# EXPOSE 8080

# Define the command to start your Node.js application
CMD ["node", "app.js"]
