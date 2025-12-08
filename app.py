from flask import Flask, render_template

app = Flask(
    __name__,
    template_folder="app/frontend/templates",
    static_folder="app/frontend/static"
)

@app.route("/")
def home():
    return render_template("base.html")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
