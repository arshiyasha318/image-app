import os
import uuid
import boto3
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)

# Load env vars
AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
AWS_REGION = os.getenv("AWS_REGION")
S3_BUCKET = os.getenv("S3_BUCKET")

# Boto3 client
s3 = boto3.client(
    "s3",
    region_name=AWS_REGION,
    aws_access_key_id=AWS_ACCESS_KEY,
    aws_secret_access_key=AWS_SECRET_KEY
)

@app.route("/api/upload", methods=["POST"])
def get_presigned_url():
    try:
        data = request.get_json(force=True)
        content_type = data.get('content_type', 'image/jpeg')  # Use same key as frontend
        key = f"{uuid.uuid4()}.jpg"  # or infer extension later

        presigned_url = s3.generate_presigned_url(
            'put_object',
            Params={'Bucket': S3_BUCKET, 'Key': key, 'ContentType': content_type},
            ExpiresIn=3600,
        )

        return jsonify({"url": presigned_url, "key": key})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/images", methods=["GET"])
def list_images():
    try:
        objects = s3.list_objects_v2(Bucket=S3_BUCKET)
        images = []
        for obj in objects.get("Contents", []):
            key = obj["Key"]
            url = s3.generate_presigned_url(
                'get_object',
                Params={'Bucket': S3_BUCKET, 'Key': key},
                ExpiresIn=3600
            )
            images.append({"key": key, "url": url})
        return jsonify(images)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
