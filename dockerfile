# Use official Python image
FROM python:3.9.0

# # Set environment variables
# ENV PYTHONUNBUFFERED=1
# ENV LEARN_OPS_DB=defaultdb
# ENV LEARN_OPS_USER=doadmin
# ENV LEARN_OPS_PASSWORD=AVNS_a-QoiCj6MfGqjcg7wO8
# ENV LEARN_OPS_HOST=learn-ops-prod-apollo-ascend-do-user-18311930-0.d.db.ondigitalocean.com
# ENV LEARN_OPS_PORT=25060

# Set the working directory
WORKDIR /app

# Install system dependencies (including Nginx)
RUN apt-get update && apt-get install -y \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Copy the Django requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Run migrations and load fixtures
# RUN python manage.py migrate && python manage.py loaddata complete_backup.json

# Copy the Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Expose ports for Nginx
EXPOSE 80 443

# Start Nginx and Gunicorn together
CMD service nginx start && gunicorn your_project_name.wsgi:application --bind 0.0.0.0:8000
