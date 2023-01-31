#!/bin/bash

# Define a function to print an informational message
info() {
    echo "[INFO] $1"
}

# Define a function to print a warning message
warning() {
    echo "[WARNING] $1"
}

# Define a function to print an error message
error() {
    echo "[ERROR] $1"
}

# Run the tests
python -m unittest discover app > /dev/null 2>&1

# Check if the tests passed
if [ $? -ne 0 ]; then
  error "Python unittests Tests failed, exiting..."
  exit 1
else
  info "Python unittests passed"
fi

# Build the Docker image
docker build -t greetings:latest . > /dev/null 2>&1

# Check if docker build successfuly
if [ $? -ne 0 ]; then
  error "docker buuild failed, exiting..."
  exit 1
else
  info "Docker build succeed"
fi

# Start a container from the image
docker run -tid -p 8080:8000 --name greetings greetings:latest >/dev/null 2>&1

# Check if container start successfuly
status=`docker inspect --format '{{json .State.Running}}' greetings`

# Check if docker build successfuly
if ($status) ; then
  info "greetings container start successfully"
else
  error "container faild to start check container logs (docker logs -f greetings), exiting..."
  exit 1
fi

sleep 2

# Test the API function
test_api() {
    curl -s localhost:8080/$1 #> /dev/null 2>&1
    if [ $? -ne 0 ]; then
        error "API test for customer $1 failed, exiting..."
        exit 1
    else
        info "API test for customer $1 passed"
    fi
}

test_api A
test_api B
test_api C

# Stop and remove the container
docker stop greetings >/dev/null 2>&1 && docker rm greetings > /dev/null 2>&1

# Tag the image with the version number
docker tag greetings:latest registry.lab.io:5000/greetings:latest > /dev/null 2>&1

# Push the image to the container registry
docker push registry.lab.io:5000/greetings:latest
