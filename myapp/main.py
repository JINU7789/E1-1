from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "변경 후 서버"

@app.route("/hello")
def hello():
    return "Hello, Docker! 🐳"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)