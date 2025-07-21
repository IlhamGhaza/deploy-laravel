# One-Command Laravel Deployment Script

[](https://laravel.com)
[](https://php.net)
[](https://www.google.com/search?q=LICENSE)

Deploy any Laravel application to a fresh Ubuntu/Debian VPS in minutes with a single command. This script automates the entire process, from server setup and software installation to application configuration and security hardening, letting you focus on your code.

## 📚 Documentation

  - [Quick Setup Guide (English)](https://www.google.com/search?q=QUICK-SETUP-EN.md)
  - [Quick Setup Guide (Bahasa Indonesia)](https://www.google.com/search?q=QUICK-SETUP.md)

-----

## ✨ Why Use This Script?

Deploying a Laravel application involves repetitive and error-prone tasks: installing the correct software, configuring Nginx, setting up a database, managing permissions, and securing the server. This script automates all of it, providing a production-ready environment out of the box.

  - 🚀 **One-Command Deployment:** Run a single command and let the script handle everything else.
  - 🔒 **Secure by Default:** Implements best practices for security, including SSL, secure permissions, and Nginx rate limiting.
  - ⚡ **Optimized for Performance:** Automatically enables caching for routes, config, and views for a faster application.
  - 🤖 **Smart & Flexible:** Auto-detects the default branch (`main`, `master`, `pupuk`) or lets you specify one.
  - 🔧 **Zero Manual Configuration:** No need to edit Nginx configs or create database users manually. The script handles it all.

-----

## 🛠️ What The Script Automates

### 1\. Software Installation

  - **PHP:** Installs the latest version and necessary extensions (`pgsql`, `zip`, `gd`, `curl`, etc.).
  - **PostgreSQL:** Sets up the database server.
  - **Nginx:** Installs and configures the web server.
  - **Composer:** Installs the latest version for dependency management.
  - **Certbot:** Installs Certbot and the Nginx plugin for easy SSL setup.

### 2\. Application & Environment Setup

  - **Clone Repository:** Clones your Laravel project into `/var/www/<repo_name>`.
  - **Database Creation:** Creates a PostgreSQL database (`laravel_pos`) and a user (`laravel_pos_app`) with a securely generated password.
  - **.env Configuration:** Copies `.env.example` and automatically configures `APP_URL`, database credentials, and sets the environment to `production`.
  - **Dependency Installation:** Runs `composer install --optimize-autoloader`.
  - **Laravel Setup:**
      - Generates an application key (`php artisan key:generate`).
      - Runs database migrations and seeders (`php artisan migrate:fresh --seed`).
      - Creates the storage link (`php artisan storage:link`).

### 3\. Security Hardening

  - **SSL Certificate:** Obtains and installs a free SSL certificate from Let's Encrypt for your domain and `www` subdomain.
  - **Secure Permissions:** Sets correct ownership (`www-data:www-data`) and permissions for project files, while keeping storage directories writable.
  - **Nginx Security:**
      - Adds security headers (`X-Frame-Options`, `X-Content-Type-Options`).
      - Denies access to hidden files (like `.env`) and the `bootstrap/cache` directory.
      - Implements API rate limiting (100 requests/second).

### 4\. Performance Optimization

  - **Caching:** Automatically runs `php artisan optimize`, `config:cache`, `route:cache`, and `view:cache`.
  - **Optimized Autoloader:** Installs Composer dependencies with `--optimize-autoloader` for faster class loading.
  - **Production Mode:** Sets `APP_ENV=production` and `APP_DEBUG=false`.

-----

## 🚀 Quick Start

**Prerequisites:**

  - A fresh Ubuntu/Debian VPS.
  - A domain name pointed to your VPS IP address.
  - Root or `sudo` access.
  - A valid Laravel repository URL.

**1. Download the script:**

```bash
wget https://raw.githubusercontent.com/IlhamGhaza/deploy-laravel/master/deploy-laravel.sh
```

**2. Make it executable:**

```bash
chmod +x deploy-laravel.sh
```

**3. Run the deployment:**

```bash
sudo ./deploy-laravel.sh <repo_url> [branch] <domain> <email>
```

### Usage Examples

**Deploying with a specific branch:**

```bash
sudo ./deploy-laravel.sh https://github.com/laravel/laravel.git main example.com admin@example.com
```

**Deploying without a branch (auto-detects `main`/`master`/`pupuk`):**

```bash
sudo ./deploy-laravel.sh https://github.com/laravel/laravel.git example.com admin@example.com
```

-----

## 🔧 Post-Deployment & Maintenance

Your application will be deployed to `/var/www/<repo_name>`.

**Common Commands:**

```bash
# Check service status
sudo systemctl status nginx php-fpm postgresql

# View Nginx logs
sudo tail -f /var/log/nginx/error.log

# View Laravel logs
sudo tail -f /var/www/<repo_name>/storage/logs/laravel.log
```

For more commands and troubleshooting, see the [**Quick Setup Guide**](https://www.google.com/search?q=QUICK-SETUP-EN.md%23troubleshooting--useful-commands).

## 🆘 Troubleshooting

If you encounter issues, please consult the detailed troubleshooting guides:

  - [English Documentation](https://www.google.com/search?q=QUICK-SETUP-EN.md%23troubleshooting--useful-commands)
  - [Indonesian Documentation](https://www.google.com/search?q=QUICK-SETUP.md%23troubleshooting--perintah-penting)

## 🤝 Contributing

Contributions are welcome\! If you have suggestions or improvements, please feel free to submit a Pull Request.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.