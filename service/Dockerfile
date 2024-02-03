# Use the official Python 3.10 base image
FROM python:3.10-bookworm

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy the requirements file to the working directory
COPY requirements.txt .

# Install the required Python packages
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt -t .

# Install gunicorn
RUN apt-get update -y
RUN apt-get install gunicorn -y

# Copy the application code to the working directory
COPY . .

# Create a non-root user to run the application
RUN adduser --disabled-login --disabled-password --gecos "" roundsfilesserver
RUN chown -R roundsfilesserver:roundsfilesserver /usr/src/app

# Set the command to run the application with the non-root user
USER roundsfilesserver

# Expose port
EXPOSE 8000

CMD ["gunicorn", "-w", "1", "-b", "0.0.0.0", "app:app"]