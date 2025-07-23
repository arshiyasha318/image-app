import React, { useState, useEffect } from 'react';
import axios from 'axios';

const backendURL = "http://k8s-imageapp-0a0239dfa2-1273944766.us-east-1.elb.amazonaws.com/api"; // Replace with your backend URL

function App() {
  const [image, setImage] = useState(null);
  const [images, setImages] = useState([]);

  useEffect(() => {
    fetchImages();
  }, []);

  const fetchImages = async () => {
    try {
      const res = await axios.get(`${backendURL}/images`);
      setImages(res.data);
    } catch (err) {
      console.error("Error loading images:", err);
    }
  };

  const handleChange = (e) => {
    setImage(e.target.files[0]);
  };

  const handleUpload = async () => {
    if (!image) return alert("Please choose an image!");

    try {
      // Request presigned URL from backend
      const { data } = await axios.post(`${backendURL}/upload`, {
        content_type: image.type,
      });

      // Upload directly to S3 using PUT
      await axios.put(data.url, image, {
        headers: {
          "Content-Type": image.type,
        },
      });

      alert("Upload successful!");
      setImage(null);
      fetchImages();
    } catch (err) {
      console.error("Upload failed:", err);
      alert("Upload failed");
    }
  };

  return (
    <div style={{ padding: 40, fontFamily: "Arial" }}>
      <h1>🖼️ Image Uploader</h1>
      <input type="file" accept="image/*" onChange={handleChange} />
      <button onClick={handleUpload} style={{ marginLeft: 10 }}>
        Upload
      </button>

      <hr style={{ margin: "40px 0" }} />

      <h2>Uploaded Images</h2>
      <div style={{ display: "flex", flexWrap: "wrap", gap: 20 }}>
        {images.map((img, i) => (
          <img
            key={i}
            src={img.url}
            alt={img.key}
            style={{ width: 200, borderRadius: 8 }}
          />
        ))}
      </div>
    </div>
  );
}

export default App;
