# Greetings Application

This application is a simple REST-API service that responds with different salutations for customers.
This code implements a Flask app that has liveness and readiness endpoints in addition to the / endpoint. Wich will serve customer A, B, or C based on os enviroment passed to the application. The liveness and readiness endpoints can be used to check if the app is healthy and ready to handle requests.

[cdk8s](https://cdk8s.io/docs/latest/getting-started/) is a tool that I used for writing Kubernetes manifests using familiar programming concepts. With cdk8s, you can define your application infrastructure using Python classes and methods, instead of writing raw YAML manifests. 

## Prerequisites
- Python3
- pip
- cdk8s
- cdk8s_plus_25

## Manually Deployment

#### Install python virtual environment
```sh
sudo apt-get install python3-venv
```
#### Create a virtual environment and activate it
```sh
python3 -m venv .venv
source .venv/bin/activate
```
#### Install the required dependencies
```sh
pip install -r requirements.txt
```
#### Run the tests
```sh
python -m unittest greetings_test.py
```
#### Start the application per Customer
```sh
export CUSTOMER=A
flask --app greetings.py run
```
#### Test the API by sending a GET request to the endpoint for each customer
```sh
curl -s localhost:5000
"Hi"
```

## Automated Deployment
You can use the provided pipeline script to build, test, lint, and deploy the application in one command
```sh
chmod +x ./pipeline.sh
./pipeline.sh
```
or using Makefile to run targeted tasks 
```sh 
make all
```
### This script will:
- Run the tests
- Build the Docker image
- Push the image to a container registry
- Deploy the application to a Kubernetes cluster

### Get confirmation that the application succesfully deployed on k8s cluster, IP_ADDRESS is loadbalancer ip or ingress controler ip.
```sh
curl -k --header 'Host: a.lab.io' https://IP_ADDRESS/
curl -k --header 'Host: b.lab.io' https://IP_ADDRESS/
curl -k --header 'Host: c.lab.io' https://IP_ADDRESS/
```

### To use cdk8s to make some changes
- install cdk8s from [documentation](https://cdk8s.io/docs/latest/getting-started/)
- navigate to manifest/cdk8s
- do some changes
- run
```sh
cdk8s synth
```
- The output will be found in dist directory.


### Conclusion
By following this guide, you should now have a working deployment of your Greetings application. You can use this pipeline to automatically deploy new versions of your application as you make changes and push them to the repository.
