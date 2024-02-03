import os
from flask import Flask, request
from werkzeug.utils import secure_filename
from google.cloud import storage

app = Flask(__name__)


def post_handler_root():
    file = request.files['file']
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(os.environ['BUCKET_NAME'])
    blob = bucket.blob(secure_filename(file.filename))
    blob.upload_from_string(file.read(), content_type=file.content_type)
    return blob.public_url


@app.route("/", methods=["GET", "POST"])
def hello_world():
    if request.method == 'POST':
        file_url = post_handler_root()
        para = f"<p>Upload success: {file_url}</p>"

    return f'''
    <!doctype html>
    <title>Upload new File</title>
    <h1>Upload new File</h1>
    <div style="margin-bottom: 20px;">
        <a href="files">Files</a>
    </div>
    <form method=post enctype=multipart/form-data>
      <input type=file name=file>
      <input type=submit value=Upload>
    </form>
    {para if request.method == 'POST' else ""}
    '''


@app.route("/files", methods=["GET"])
def list_files():
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(os.environ['BUCKET_NAME'])
    blobs = bucket.list_blobs()
    return f'''
    <!doctype html>
    <title>Files</title>
    <h1>Files</h1>
    <div style="margin-bottom: 20px;">
        <a href="/">Home</a>
    </div>
    <ul>
        {"".join([f"<li><a href='http://{os.environ['LOAD_BALANCER_IP']}/{blob.name}'>{blob.name}</a></li>" for blob in blobs])}
    </ul>
    '''


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
