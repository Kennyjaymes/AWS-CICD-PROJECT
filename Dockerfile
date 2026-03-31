FROM node:20-alpine

WORKDIR /app

# Copy package.json to the current directory
COPY app/package.json ./

# Install dependencies if there are any (none for this basic node app, but good practice)
RUN npm install

# Copy application source code
COPY app/server.js ./

# Expose port 3000
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
