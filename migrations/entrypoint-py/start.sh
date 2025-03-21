#!/bin/sh
wget https://swapi.dev/api/films -O sw.json
/usr/bin/python app.py