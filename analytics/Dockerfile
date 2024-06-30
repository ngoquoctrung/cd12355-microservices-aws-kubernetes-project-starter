# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app


# Update the local package index with the latest packages from the repositories
RUN apt update -y

# Install a couple of packages to successfully install postgresql server locally
RUN apt install -y build-essential libpq-dev

# Copy the current directory contents into the container at /app
COPY . /app

# Update python modules to successfully build the required modules
RUN pip install --upgrade pip setuptools wheel

# Install any needed packages specified in requirements.txt
RUN pip install -r requirements.txt

# Set environment variables using build arguments
ENV DB_USERNAME=myuser
ENV DB_PASSWORD=${POSTGRES_PASSWORD}
ENV DB_HOST=127.0.0.1
ENV DB_PORT=5433
ENV DB_NAME=mydatabase

EXPOSE 5153

# Run app.py when the container launches
CMD ["python", "app.py"]