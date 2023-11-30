
#Start new

# Development Stage
FROM node:16 as development

WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install application dependencies, including dev dependencies
RUN npm install

# Copy the rest of your source code to the image
COPY . .

EXPOSE 3001

# Run the start:dev command, which uses nodemon to watch for changes
CMD ["npm", "run", "start:dev"]

# Builder Stage
FROM development as builder

WORKDIR /app

# Remove the development dependencies but keep the production ones
RUN rm -rf node_modules
RUN npm ci --only=production

EXPOSE 3001

# Final Production Stage
FROM alpine:latest as production

RUN apk --no-cache add nodejs ca-certificates

WORKDIR /root/

# Copy the built assets from the "builder" stage
COPY --from=builder /app ./

CMD ["node", "app.js"]

#Finalized Application