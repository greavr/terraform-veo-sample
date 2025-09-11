# Use an official lightweight Python image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=True
ENV APP_HOME=/app

# Create and set the working directory
WORKDIR $APP_HOME

# Copy the requirements file and install dependencies
COPY . .
RUN pip install --no-cache-dir -r requirements.txt

CMD ["python3", "main.py"]