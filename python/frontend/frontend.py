from flask import Flask, render_template, Response

import requests

app = Flask(__name__)


def _fetch_backend(path: str):
    response = requests.get(f"http://backend:5000{path}")
    try:
        payload = response.json()
    except ValueError:
        payload = response.text
    return response, payload


def _extract_error(payload):
    if isinstance(payload, dict):
        return payload.get("error")
    return None


def _proxy_get(path: str) -> Response:
    backend_response = requests.get(f"http://backend:5000{path}")
    return Response(
        backend_response.content,
        status=backend_response.status_code,
        content_type=backend_response.headers.get("Content-Type", "application/json"),
    )


@app.route("/")
def home():
    return render_template("index.html")


@app.route("/movies")
def show_movies():
    response, result = _fetch_backend("/movies")
    return render_template(
        "movies.html",
        movies=result if response.ok else None,
        error=_extract_error(result),
        result=result,
        container_id=response.headers.get("X-Served-By"),
        status_code=response.status_code,
    )


@app.route("/movies/<int:id>")
def show_movie(id: int):
    response, result = _fetch_backend(f"/movies/{id}")
    return render_template(
        "movie.html",
        movie=result if response.ok else None,
        error=_extract_error(result),
        result=result,
        container_id=response.headers.get("X-Served-By"),
        movie_id=id,
        status_code=response.status_code,
    )


@app.route("/find/<path:name>")
def find_movie(name: str):
    response, result = _fetch_backend(f"/find/{name}")
    return render_template(
        "find.html",
        name=name,
        movie=result if response.ok else None,
        error=_extract_error(result),
        result=result,
        container_id=response.headers.get("X-Served-By"),
        status_code=response.status_code,
    )


@app.route("/health")
def health_check():
    return _proxy_get("/health")


if __name__ == '__main__':
    app.run(host="0.0.0.0")