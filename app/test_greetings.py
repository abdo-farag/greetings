# Importing the Flask application instance and customers dictionary from the greetings module
from unittest import TestCase
from greetings import app, customers
import os

# Defining the TestGreetingsAPI test case
class TestGreetingsAPI(TestCase):        
    # The setup method is called before each test method is run
    def setUp(self):
        # Assigning the Flask application instance to self.app
        self.app = app
        # Setting the testing flag to True on the Flask application instance
        self.app.testing = True
        # Creating a test client for the Flask application instance
        self.client = self.app.test_client()
           

    # Testing the response of the "/A" endpoint
    def test_greet_customer_A(self):    
        # Sending a GET request to the "/A" endpoint using the test client
        response = self.client.get("/")
        # Asserting that the response has a status code of 200 (OK)
        self.assertEqual(response.status_code, 200)
        # Asserting that the response has the correct greeting for customer A
        self.assertEqual(response.get_json(), customers.get("A"))


    # Testing the response of the "/B" endpoint
    def test_greet_customer_B(self):
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json(), customers.get("B"))

    # Testing the response of the "/C" endpoint
    def test_greet_customer_C(self):
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json(), customers.get("C"))
    
    # Testing the response of the "/healthz/live" endpoint
    def test_liveness(self):
        response = self.client.get("healthz/live")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.status, "200 OK" )

    # Testing the response of the "/healthz/ready" endpoint
    def test_readiness(self):
        response = self.client.get("/healthz/ready")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.status, "200 OK" )
