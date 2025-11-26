from flask import Flask, jsonify
import socket

app = Flask(__name__)
hostname = socket.gethostname()

movies = [
    {"id": 1, "name": "The Shawshank Redemption", "year": 1994},
    {"id": 2, "name": "The Godfather", "year": 1972},
    {"id": 3, "name": "The Dark Knight", "year": 2008},
    {"id": 4, "name": "Pulp Fiction", "year": 1994},
    {"id": 5, "name": "Forrest Gump", "year": 1994},
]


@app.route("/health")
def health_check():
    return "OK", 200


@app.route("/movies")
def get_all_movies():
    return jsonify(movies)


@app.route("/movies/<int:id>")
def get_movie(id):
    movie = next((movie for movie in movies if movie["id"] == id), None)
    if movie:
        return jsonify(movie)
    else:
        return jsonify({"error": "Movie not found"}), 404


@app.route("/find/<name>")
def find_movie_by_name(name):
    movie = next((movie for movie in movies if movie["name"] == name), None)
    if movie:
        return jsonify(movie)
    else:
        return jsonify({"error": "Movie not found"}), 404
 

@app.after_request
def after_request(response):
    response.headers.add("X-Served-By", hostname)
    return response


if __name__ == "__main__":
    app.run("0.0.0.0")