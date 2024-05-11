FROM tiangolo/uvicorn-gunicorn-fastapi:latest

# Install system dependencies
RUN apt-get update && \
    apt-get install -y libsm6 libxext6 libxrender-dev

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# Copy the application code and the model
COPY . /garbage-classification.h5
COPY . /app

# Start the FastAPI application
# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
