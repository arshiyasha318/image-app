import os
import uuid
import boto3
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)

AWS_REGION = os.getenv("AWS_REGION")
S3_BUCKET = os.getenv("S3_BUCKET")

# ❌ Remove hardcoded credentials
# ✅ Use default session so IRSA is picked up
s3 = boto3.client("s3", region_name=AWS_REGION)

@app.route("/api/upload", methods=["POST"])
def get_presigned_url():
    try:
        data = request.get_json(force=True)
        content_type = data.get('content_type', 'image/jpeg')
        key = f"{uuid.uuid4()}.jpg"

        presigned_url = s3.generate_presigned_url(
            'put_object',
            Params={'Bucket': S3_BUCKET, 'Key': key, 'ContentType': content_type},
            ExpiresIn=3600,
        )

        return jsonify({"url": presigned_url, "key": key})
    except Exception as e:
        import traceback
        print("Error in /api/upload:", e)
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500
