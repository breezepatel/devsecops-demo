# Build Stage
FROM node:20-alpine AS build
WORKDIR /app

# Update Alpine package index and upgrade all installed packages
RUN apk update && apk upgrade

# Copy the package files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy the rest of the app files and build the app
COPY . . 
RUN npm run build

# Production Stage
FROM nginx:alpine

# Update Alpine package index and upgrade all installed packages in nginx image
RUN apk update && apk upgrade

# Copy the built app from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Expose the default port
EXPOSE 80

# Run nginx
CMD ["nginx", "-g", "daemon off;"]
