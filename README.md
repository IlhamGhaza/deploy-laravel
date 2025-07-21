# Laravel Automated Deployment Script

[![Laravel](https://img.shields.io/badge/Laravel-red.svg)](https://laravel.com)
[![PHP](https://img.shields.io/badge/PHP-purple.svg)](https://php.net)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A robust, automated deployment script for Laravel applications on Ubuntu/Debian VPS. This tool simplifies the entire deployment process from setup to maintenance.

## 📚 Documentation
- [Quick Setup (English)](QUICK-SETUP-EN.md)
- [Quick Setup (Indonesia)](QUICK-SETUP.md)

## ✨ Features

- 🚀 One-command deployment
- 🔒 Secure configuration out of the box
- 🤖 Automated software installation
- 🗄️ PostgreSQL database setup
- 🔑 SSL certificate configuration
- ⚡ Performance optimizations
- 🛡️ Laravel Shield integration
- 📊 Smart branch detection
- 🔧 Zero-downtime deployment
- 🌐 Multi-language documentation

## 🛠️ Prerequisites

- Ubuntu/Debian VPS
- Root/sudo access
- Domain pointed to VPS IP
- Git installed
- Valid Laravel repository

## 📦 What's Included

### Automated Software Installation
- PHP 8.x with extensions
- PostgreSQL database
- Nginx web server
- Certbot for SSL
- Composer

### Security Features
- SSL/TLS encryption
- Secure file permissions
- Production environment settings
- Database security
- Nginx security headers
- Rate limiting
- Protected system files

### Performance Optimizations
- Route caching
- Config caching
- View caching
- Composer optimization
- Nginx performance settings

## 🚀 Quick Start

1. Download the script:
```bash
wget https://raw.githubusercontent.com/IlhamGhaza/deploy-laravel/master/deploy-laravel.sh
```

2. Make it executable:
```bash
chmod +x deploy-laravel.sh
```

3. Run deployment:
```bash
sudo ./deploy-laravel.sh <repo_url> [branch] <domain> <email>
```

### Usage Examples

With specific branch:
```bash
sudo ./deploy-laravel.sh https://github.com/laravel/laravel.git main example.com admin@example.com
```

Without branch (auto-detects main/master/pupuk):
```bash
sudo ./deploy-laravel.sh https://github.com/laravel/laravel.git example.com admin@example.com
```

## 📋 Directory Structure

After deployment, your application will be structured as:
```
/var/www/<repo_name>/
├── app/
├── bootstrap/
├── config/
├── database/
├── public/
├── resources/
├── routes/
├── storage/
└── .env
```

## 🔧 Maintenance

### Common Commands

Check services:
```bash
sudo systemctl status nginx php-fpm postgresql
```

View logs:
```bash
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/www/<repo_name>/storage/logs/laravel.log
```

Fix permissions:
```bash
sudo chown -R www-data:www-data /var/www/<repo_name>
sudo chmod -R 755 /var/www/<repo_name>
sudo chmod -R 777 /var/www/<repo_name>/storage
```

## 🆘 Troubleshooting

Common issues and solutions are documented in:
- [English Documentation](QUICK-SETUP-EN.md#troubleshooting--useful-commands)
- [Indonesian Documentation](QUICK-SETUP.md#troubleshooting--perintah-penting)

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

If you encounter any problems or have questions:
1. Check the troubleshooting guides
2. Open an issue in this repository
3. Provide detailed information about your setup and the error encountered

## 🌟 Star History

If you find this tool useful, please consider giving it a star ⭐️ to help others discover it.
