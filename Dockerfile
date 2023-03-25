# Use an official Node.js runtime as a parent image
FROM node:14

# Set the working directory to /app
WORKDIR /app

# Copy the package.json and yarn.lock files to the container
COPY package.json /app/

# Install dependencies using yarn
RUN yarn install --no-optional && npm cache clean --force

# Copy the rest of the application code to the container
COPY . /app/

# Expose port 3000
EXPOSE 3000

# Start the application
CMD ["node", "index.js"]