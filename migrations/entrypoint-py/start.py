import os
import sys
import requests

response = requests.get('https://swapi.dev/api/films')

with open('sw.json', 'w') as f:
    f.write(response.text)

command=['venv/bin/python', 'app.py']
os.execvp(command[0], command)

