# Use the Python 3.9 Alpine base image
FROM python:3.9-alpine

# Create a non-root user 'app'
RUN adduser -D app

# Create a directory 'greetings' in the home directory of the app user
RUN mkdir -p /home/app/greetings

# Copy the app code to the 'greetings' directory
COPY --chown=app:app ./app/  /home/app/greetings

# Set the working directory to the 'greetings' directory
WORKDIR /home/app/greetings

# Upgrade pip and install the required dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Set the user to the non-root user 'app'
USER app

# Adjust customer name
ENV CUSTOMER ''

# Expose port 8000 to the outside world
EXPOSE 8000

# Set the entrypoint to gunicorn
ENTRYPOINT ["gunicorn"]

# Pass the command to run the app with gunicorn
CMD ["-b", "0.0.0.0:8000", "wsgi:app"]