import requests
import subprocess
response = requests.get('https://swapi.dev/api/films')

with open('sw.json', 'w') as f:
    f.write(response.text)

# now run the app.py as a subprocess
subprocess.run(['venv/bin/python', 'app.py'])
