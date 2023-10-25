# Use an official Node.js runtime as the base image
FROM node:14

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install application dependencies
RUN npm install

# Copy the rest of your application code to the container
COPY . .

# Expose the port your application listens on (if necessary)
# Replace with the actual port your Node.js app listens on
EXPOSE 3000

# Define the command to start your Node.js application
CMD ["node", "app.js"]
