#!/usr/bin/env bash

# Build the images from the Dockerfiles
docker-compose build

# Stop and remove containers and networks
docker-compose down

# Start the container network
docker-compose up -d

# Run Composer (update or install)
docker-compose exec app composer update
# If you don't want to run the Symfony commands
docker-compose exec app composer update --no-scripts

# Run Yarn/Webpack
docker-compose exec app yarn install
# If you don't want to update your packages
docker-compose exec app yarn install --frozen-lockfile
docker-compose exec app yarn dev-server