# First, create a Docker container to generate yarn.lock
FROM node:14-alpine as build

# Set the working directory to /app
WORKDIR /app

# Copy package.json and yarn.lock into the container at /app
COPY package*.json  ./

# Install dependencies using yarn
RUN yarn install --frozen-lockfile

# Second, create a new Docker container with only the necessary files
FROM node:14-alpine

# Set the working directory to /app
WORKDIR /app

# Copy package.json and yarn.lock into the container at /app
COPY package.json ./

# Copy the rest of the application
COPY . .

# Expose port 3000
EXPOSE 3000

# Start the application
CMD ["yarn", "start"]
