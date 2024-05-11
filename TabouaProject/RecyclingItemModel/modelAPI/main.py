from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
import tensorflow as tf
import numpy as np
from PIL import Image
import io
import os


app = FastAPI()

# Initialize the model variable
model = None

# Define the target image size
target_size = (384, 384)

# Define the mapping between class indices and labels
class_names = ['كرتون', 'أقمشة', 'إلكترونيات', 'زجاج', 'معدن', 'ورق', 'بلاستيك', "نفايات لا يعاد تدويرها"]

# Function to lazily load the model
def load_model():
    global model
    if model is None:
        model_path = "garbage_classification.h5"
        model = tf.keras.models.load_model(model_path)

# Endpoint for waste classification
@app.post("/classify")
async def classify_waste(file: UploadFile = File(...)):
    try:
        # Ensure the model is loaded
        load_model()

        contents = await file.read()
        image = Image.open(io.BytesIO(contents)).convert("RGB")
        image = image.resize(target_size)

        # Check if the image is solid color
        if is_solid_or_empty(image):
            return JSONResponse(content={"waste_type": "none"})

        # Make prediction
        predictions = model.predict(np.expand_dims(image, axis=0))

        # Get the index of the class with the highest probability
        pred_class_index = np.argmax(predictions[0])
        pred_class_prob = predictions[0][pred_class_index]*100
        pred_class = class_names[pred_class_index]

        # Return the result with class name and probability
        return JSONResponse(content={"waste_type": pred_class, "probability": float(pred_class_prob)})
    except Exception as e:
        # Handle any exceptions that may occur during processing
        return HTTPException(status_code=500, detail=str(e))


def is_solid_or_empty(image, variance_threshold=10):

    # Convert the image to a numpy array if it's not already
    if not isinstance(image, np.ndarray):
        img_array = np.array(image)
    else:
        img_array = image

    # Ensure the image is in RGB format
    if img_array.ndim == 3 and img_array.shape[2] == 3:
        # Convert image to grayscale using the luminosity method
        gray_img = 0.2989 * img_array[:, :, 0] + 0.5870 * img_array[:, :, 1] + 0.1140 * img_array[:, :, 2]
    elif img_array.ndim == 2 or (img_array.ndim == 3 and img_array.shape[2] == 1):
        # Image is already grayscale
        gray_img = img_array
    else:
        raise ValueError("Image format not recognized. Ensure it is either grayscale or RGB.")

    # Calculate the variance of the pixel values
    variance = np.var(gray_img)

    # If the variance is below a certain threshold, it's likely a solid color or empty
    return variance < variance_threshold


