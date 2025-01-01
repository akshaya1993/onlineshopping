# Use the official Nginx image as the base
FROM nginx:alpine

# Copy the HTML files into the Nginx web directory
COPY onlineshopping.html /usr/share/nginx/html/index.html
COPY error.html /usr/share/nginx/html/error.html

# Expose port 80
EXPOSE 80

