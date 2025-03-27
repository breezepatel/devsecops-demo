# Build Stage
FROM node:20-alpine AS build
WORKDIR /app
# Update Alpine package index and upgrade vulnerable libraries
RUN apk update && apk upgrade
# Install any necessary dependencies (if specific ones need upgrading)
RUN apk add --no-cache libexpat=2.7.0-r0 libxml2=2.13.4-r4 libxslt=1.1.42-r2
# Copy the package files and install dependencies
COPY package*.json ./
RUN npm ci
# Copy the rest of the app files and build the app
COPY . . 
RUN npm run build

# Production Stage
FROM nginx:alpine
# Update Alpine package index and upgrade vulnerable libraries in nginx image
RUN apk update && apk upgrade
# Install any necessary dependencies (if specific ones need upgrading)
RUN apk add --no-cache libexpat=2.7.0-r0 libxml2=2.13.4-r4 libxslt=1.1.42-r2
# Copy the built app from the build stage
COPY --from=build /app/dist /usr/share/nginx/html
# Expose the default port
EXPOSE 80
# Run nginx
CMD ["nginx", "-g", "daemon off;"]