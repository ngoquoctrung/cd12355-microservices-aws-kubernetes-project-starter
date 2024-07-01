# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Working directory
WORKDIR /app

# Copy the rest of the application code to the working directory
COPY  /analytics/ /app

# Python dependencies
RUN pip install -r /app/requirements.txt

# Expose port 5153
EXPOSE 5153

# Command to run the application
CMD python app.py