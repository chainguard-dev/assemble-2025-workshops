from flask import Flask
import os
import json

app = Flask(__name__)

@app.route('/')
def hello():

    with open('sw.json', 'r') as f:
        movies_data = json.load(f)
    
    # Get the count and movie titles
    movie_count = movies_data['count']
    movie_titles = [movie['title'] for movie in movies_data['results']]
    
    # Create HTML response
    html_response = f"""
    <h1>Star Wars Movies Summary</h1>
    <p>Number of movies: {movie_count}</p>
    <h2>Movie Titles:</h2>
    <ul>
        {''.join(f'<li>{title}</li>' for title in movie_titles)}
    </ul>
    """
    
    return html_response

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True) 