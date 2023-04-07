FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements.txt and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Expose the port the app runs on
EXPOSE 8000

# Start the application
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]