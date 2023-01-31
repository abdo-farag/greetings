info:
	@echo "[INFO] $1"

warning:
	@echo "[WARNING] $1"

error:
	@echo "[ERROR] $1"

test:
	@python -m unittest discover app > /dev/null 2>&1 || (error "Tests failed, exiting..."; exit 1)
	$(info "Python Unittests passed")

build:
	@docker build -t greetings:latest .

run:
	@docker run -tid -p 8080:8000 --name greetings greetings:latest 

test-api:
	@sleep 2
	@curl -s localhost:8080/A || (error "API test for customer A failed, exiting..."; exit 1)
	$(info "API test for customer A passed")
	@curl -s localhost:8080/B || (error "API test for customer B failed, exiting..."; exit 1)
	$(info "API test for customer B passed")
	@curl -s localhost:8080/C || (error "API test for customer C failed, exiting..."; exit 1)
	$(info "API test for customer C passed")

stop:
	@docker stop greetings
	@docker rm greetings

tag:
	@docker tag greetings:latest registry.lab.io:5000/greetings:latest

push:
	@docker push registry.lab.io:5000/greetings:latest

#deploy:
#	@kubectl apply -f k8s/deployment.yml

all: test build run test-api stop tag push deploy
