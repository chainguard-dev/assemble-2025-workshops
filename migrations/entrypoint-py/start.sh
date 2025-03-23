#!/bin/sh
wget https://swapi.dev/api/films -O sw.json
exec /usr/bin/python app.py
