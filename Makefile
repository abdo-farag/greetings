info:
	@echo "[INFO] $1"

warning:
	@echo "[WARNING] $1"

error:
	@echo "[ERROR] $1"

test:
	@cd app && \
	unset CUSTOMER && \
	export CUSTOMER=A && python -m unittest test_greetings.py -k test_greet_customer_A > /dev/null 2>&1 && \
	unset CUSTOMER && \
	export CUSTOMER=B && python -m unittest test_greetings.py -k test_greet_customer_B > /dev/null 2>&1 && \
	unset CUSTOMER && \
	export CUSTOMER=C && python -m unittest test_greetings.py -k test_greet_customer_C > /dev/null 2>&1 && \
	unset CUSTOMER 
	@cd -  > /dev/null 2>&1
	$(info "Python Unittests passed")

build:
	@docker build -t greetings:latest .

run:
	@docker run -tid -p 8081:8000 --name greetings-a -e CUSTOMER='A' greetings:latest 
	@docker run -tid -p 8082:8000 --name greetings-b -e CUSTOMER='B' greetings:latest 
	@docker run -tid -p 8083:8000 --name greetings-c -e CUSTOMER='C' greetings:latest 

test-api:
	@sleep 2
	@curl -s localhost:8081/ || (error "API test for customer A failed, exiting..."; exit 1)
	$(info "API test for customer A passed")
	@curl -s localhost:8082/ || (error "API test for customer B failed, exiting..."; exit 1)
	$(info "API test for customer B passed")
	@curl -s localhost:8083/ || (error "API test for customer C failed, exiting..."; exit 1)
	$(info "API test for customer C passed")

stop:
	@docker rm -f greetings-a greetings-b greetings-c

tag:
	@docker tag greetings:latest registry.lab.io:5000/greetings:latest

push:
	@docker push registry.lab.io:5000/greetings:latest

deploy:
	@kubectl apply -f manifest/cdk8s/dist/a.k8s.yaml -f manifest/cdk8s/dist/b.k8s.yaml -f manifest/cdk8s/dist/c.k8s.yaml

all: test build run test-api stop tag push deploy
