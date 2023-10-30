# Build Stage
FROM node:14 as build
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install application dependencies for the build
RUN npm install

# Copy the rest of your application code to the container
COPY . .

# Build your application (if necessary, e.g., TypeScript to JavaScript)
RUN npm run build

# Final Stage
FROM node:14
WORKDIR /app

# Copy only the necessary artifacts from the build stage to the final stage
COPY --from=build /app/package*.json /app/
COPY --from=build /app/dist /app/dist

# Install production dependencies (no devDependencies)
RUN npm install --only=production

# Expose the port your application listens on (if necessary)
# Replace with the actual port your Node.js app listens on
EXPOSE 3001

# Define the command to start your Node.js application
CMD ["node", "dist/app.js"]
