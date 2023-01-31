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
#python -m unittest discover app > /dev/null 2>&1
cd app
export CUSTOMER=A; python -m unittest test_greetings.py -k test_greet_customer_A > /dev/null 2>&1
export CUSTOMER=B; python -m unittest test_greetings.py -k test_greet_customer_B > /dev/null 2>&1
export CUSTOMER=C; python -m unittest test_greetings.py -k test_greet_customer_C > /dev/null 2>&1
cd -  > /dev/null 2>&1

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


# Test the API function
test_api() {
    curl -s localhost:808$2/ #> /dev/null 2>&1
    if [ $? -ne 0 ]; then
        error "API test for customer $1 failed, exiting..."
        docker rm -f greetings-a greetings-b greetings-c >/dev/null 2>&1
        exit 1
    else
        info "API test for customer $1 passed"
    fi
}


# Start a container from the image
docker run -tid -p 8081:8000 --name greetings-a -e CUSTOMER='A' greetings:latest >/dev/null 2>&1
docker run -tid -p 8082:8000 --name greetings-b -e CUSTOMER='B' greetings:latest >/dev/null 2>&1
docker run -tid -p 8083:8000 --name greetings-c -e CUSTOMER='C' greetings:latest >/dev/null 2>&1

# Check if container start successfuly
status=`docker inspect --format '{{json .State.Running}}' greetings-a`

# Check if docker build successfuly
if ($status) ; then
  info "greetings container start successfully"
else
  error "container faild to start check container logs (docker logs -f greetings), exiting..."
  exit 1
fi

# run test api for every customer
sleep 2
test_api A 1
test_api B 2
test_api C 3


# Stop and remove the container
docker rm -f greetings-a greetings-b greetings-c >/dev/null 2>&1
#docker stop greetings >/dev/null 2>&1 && docker rm greetings > /dev/null 2>&1

# Tag the image with the version number
docker tag greetings:latest registry.lab.io:5000/greetings:latest > /dev/null 2>&1

# Push the image to the container registry
docker push registry.lab.io:5000/greetings:latest

# deploy the application to Kubernetes Cluster
kubectl apply -f manifest/cdk8s/dist/a.k8s.yaml -f manifest/cdk8s/dist/b.k8s.yaml -f manifest/cdk8s/dist/c.k8s.yaml
