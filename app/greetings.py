from flask import Flask, jsonify
from flask_healthz import healthz, HealthError
import os


# Creating an instance of the Flask class
app = Flask("greetings")


# Reading the value of the environment variable
customer = os.getenv("CUSTOMER")

# Creating a dictionary that holds the customer's name and their specific salutation
customers = {
    "A": "Hi",
    "B": "Dear Sir or Madam",
    "C": "Moin"
}

# Creating the endpoint '/' which allows only GET requests
@app.route('/', methods=['GET'])
def greetings():
    # Get the specific salutation of the customer, if not found return "Not Found"
    greeting = customers.get(customer, "Not Found")

    # Return the salutation as a json object
    return jsonify(greeting)



# Application liveness readiness healthy check
app.register_blueprint(healthz, url_prefix="/healthz")
def running():
    return True

def liveness():
    try:
        return running()
    except Exception:
        raise HealthError("Unable to connect to the service")

def readiness():
    try:
        return running()
    except Exception:
        raise HealthError("Service not ready")

app.config.update(
    HEALTHZ={
        "live": "greetings.liveness",
        "ready": "greetings.readiness",
    }
)


