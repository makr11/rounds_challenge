import unittest
from flask import Flask
from flask_testing import TestCase

from app import app

class AppTestCase(TestCase):
    def create_app(self):
        app.config['TESTING'] = True
        return app

    def test_hello_world_get(self):
        response = self.client.get('/')
        self.assert200(response)

if __name__ == '__main__':
    unittest.main()