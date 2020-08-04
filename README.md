# wordpress

WordPress image based on oryx php-fpm image. Additional components and customization include:

- Base image is oryx php-fpm 7.4 image.
- SSH configuration for Azure App Service
- Customized nginx config for WordPress/FastCGI Cache
- FastCGI Cache Purge module installed with cache directory set to /tmp/nginx-cache
- Add redis server and phpredis extension
- Install and configure wordpress 5.4.2
- WP core is in /var/www/html and wp-content is on /home/site/wwwroot.

Please use https://github.com/sureddy1/101-azure-app-service-linux-wordpress to deploy wordpress with Azure database for MySQL.

Next Steps:

Once you deploy and install wordpress on your site, please configure these two wordpress plugins: 

- nginx helper
- redis object cache

nginx helper purges FastCGI cache whenever an update a post/page is made.

Redis object cache helps with caching database objects and connects to local redis server running on port 6379.
