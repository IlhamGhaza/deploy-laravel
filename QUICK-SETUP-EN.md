# Quick VPS Setup - Deploy Laravel (English)

[Versi Indonesia](QUICK-SETUP.md)

[![Laravel](https://img.shields.io/badge/Laravel-red.svg)](https://laravel.com)
[![PHP](https://img.shields.io/badge/PHP-purple.svg)](https://php.net)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Prerequisites
- Ubuntu/Debian VPS
- Domain pointing to VPS IP
- Root/sudo access
- Git installed
- Valid Git repository with Laravel project

## Features
- Automated installation of all required software (PHP, PostgreSQL, Nginx, Certbot)
- Automatic database setup with secure random password
- Smart branch detection (tries main/master/pupuk in order)
- Secure environment configuration
- SSL certificate setup with Let's Encrypt
- Proper file permissions and security settings
- Laravel Shield authentication setup (optional)
- Performance optimizations out of the box

## Automated Setup (Recommended)

Use the generic deployment script for any Laravel repository:

```bash
wget https://raw.githubusercontent.com/IlhamGhaza/laravel-pos/pupuk/deploy-laravel/deploy-laravel.sh
chmod +x deploy-laravel.sh
sudo ./deploy-laravel.sh <repo_url> [branch] <domain> <email>
```

**Usage examples:**

- With a specific branch:
  ```bash
  sudo ./deploy-laravel.sh https://github.com/laravel/laravel.git main mydomain.com admin@mydomain.com
  ```
- Without branch (tries main/master/pupuk):
  ```bash
  sudo ./deploy-laravel.sh https://github.com/laravel/laravel.git mydomain.com admin@mydomain.com
  ```

**Argument details:**
- `<repo_url>`: Laravel repository link (required)
- `[branch]`: Branch name (optional)
- `<domain>`: Your application domain (required)
- `<email>`: Email for SSL notifications (required)

The script will automatically:

- Install all required software:
  - PHP with required extensions
  - PostgreSQL database
  - Nginx web server
  - Certbot for SSL
  - Composer for PHP dependencies

- Set up the project:
  - Clone the Laravel repo to `/var/www/<repo_name>`
  - Create PostgreSQL database and user with secure password
  - Configure environment variables
  - Set proper file permissions
  - Install Composer dependencies
  - Run Laravel migrations and seeders
  - Set up Laravel Shield authentication (if needed)
  - Configure Nginx with optimized settings
  - Install SSL certificate

- Optimize for production:
  - Cache configuration
  - Cache routes
  - Cache views
  - Create storage links
  - Set secure file permissions
  - Configure production environment settings

## Database Setup Details

The script will:
1. Create a database named `laravel_pos`
2. Create a user named `laravel_pos_app`
3. Generate a secure random password
4. Grant necessary permissions
5. Store credentials in `.env` file

## Security Features

- SSL certificates via Let's Encrypt
- Secure file permissions
- Production environment settings
- Debug mode disabled
- Nginx security headers
- Rate limiting for API endpoints
- Protected system files
- Secure database credentials

## Manual Setup (Optional)

If you prefer manual setup, follow these steps:

1. **Install Software**
   - PHP 8.x and extensions: pgsql, zip, gd, mbstring, curl, xml, bcmath, intl
   - Composer (latest version)
   - PostgreSQL database
   - Nginx web server
   - Certbot for SSL

2. **Configure PostgreSQL**
   - Create database and user
   - Set secure password
   - Grant necessary permissions

3. **Project Setup**
   - Clone repo to `/var/www/<repo_name>`
   - Set proper ownership: `www-data:www-data`
   - Set directory permissions: 755
   - Set storage/cache permissions: 777

4. **Laravel Configuration**
   - Copy `.env.example` to `.env`
   - Configure database connection
   - Set production environment
   - Generate application key
   - Install dependencies
   - Run migrations and seeders

---

## Troubleshooting & Useful Commands

### Service Management

Check service status:
```bash
sudo systemctl status nginx php-fpm postgresql
```

Restart services:
```bash
sudo systemctl restart nginx php-fpm postgresql
```

### Log Files

View Nginx error logs:
```bash
sudo tail -f /var/log/nginx/error.log
```

View Laravel application logs:
```bash
sudo tail -f /var/www/<repo_name>/storage/logs/laravel.log
```

### Common Issues

1. **Permission Problems**
   ```bash
   sudo chown -R www-data:www-data /var/www/<repo_name>
   sudo chmod -R 755 /var/www/<repo_name>
   sudo chmod -R 777 /var/www/<repo_name>/storage
   sudo chmod -R 777 /var/www/<repo_name>/bootstrap/cache
   ```

2. **SSL Certificate Issues**
   ```bash
   sudo certbot --nginx -d yourdomain.com
   sudo certbot renew --dry-run
   ```

3. **Database Connection**
   ```bash
   sudo -u postgres psql -c "\l"  # List databases
   sudo -u postgres psql -c "\du"  # List users
   ```

4. **Nginx Configuration**
   ```bash
   sudo nginx -t  # Test configuration
   sudo systemctl reload nginx  # Reload configuration
   ```

## Environment Configuration

Your `.env` file will be configured with:

```env
# Application Settings
APP_ENV=production
APP_DEBUG=false
APP_URL=https://<domain>

# Database Configuration
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=laravel_pos
DB_USERNAME=laravel_pos_app
DB_PASSWORD=<auto_generated_secure_password>

# Performance Settings
CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync

# Security Headers
SESSION_SECURE_COOKIE=true
SESSION_COOKIE_HTTPONLY=true

---

## Important Environment Variables

Ensure your `.env` contains:
```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://<domain>

DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=laravel_pos
DB_USERNAME=laravel_pos_app
DB_PASSWORD=your_secure_password

CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync
```

---

For more details, check your repo's README or documentation. 
