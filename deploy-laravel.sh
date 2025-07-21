#!/bin/bash

# Generic Laravel Deployment Script (No Docker, No Redis)
# This script automates the deployment process for any Laravel repo

set -e  # Exit on any error

# Global variables
DB_PASSWORD=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to clean up old setup files
cleanup_old_files() {
    print_status "Cleaning up any old setup files..."

    # List of files that might cause errors
    local old_files=(
        "setup-database.sh"
        "setup.sh"
        "install.sh"
        "database-setup.sh"
        "setup-laravel.sh"
        "deploy-old.sh"
        "install-laravel.sh"
    )

    # Remove any old setup files that might cause errors
    for file in "${old_files[@]}"; do
        if [ -f "$file" ]; then
            print_warning "Found old $file file, removing..."
            rm -f "$file"
        fi

        # Also check in current directory with different extensions
        if [ -f "${file%.*}" ]; then
            print_warning "Found old ${file%.*} file, removing..."
            rm -f "${file%.*}"
        fi
    done

    # Check for any executable files that might be old setup scripts
    if [ -d "." ]; then
        for file in *.sh; do
            if [[ -f "$file" && "$file" != "deploy-pos.sh" ]]; then
                print_warning "Found additional script file: $file"
                if [[ "$file" == *"setup"* ]] || [[ "$file" == *"install"* ]] || [[ "$file" == *"database"* ]]; then
                    print_warning "Removing potentially problematic script: $file"
                    rm -f "$file"
                fi
            fi
        done
    fi

    print_success "Cleanup completed"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to validate email format
validate_email() {
    local email=$1
    if [[ $email =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate domain format
validate_domain() {
    local domain=$1
    if [[ $domain =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run this script as root or with sudo"
        exit 1
    fi
}

# Function to verify script environment
verify_environment() {
    print_status "Verifying script environment..."

    # Check if .env.example exists in current directory (should be /var/www/laravel-pos)
    if [ ! -f ".env.example" ]; then
        print_error "Missing .env.example file in $(pwd). Repository clone might have failed."
        exit 1
    fi

    print_success "Environment verification completed"
}

# Function to install required software
install_software() {
    print_status "Installing required software..."

    # Update system
    apt update && apt upgrade -y

    # Add PHP PPA if not already added
    if ! grep -q "ondrej/php" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
        print_status "Adding PHP repository..."
        apt install -y software-properties-common
        add-apt-repository ppa:ondrej/php -y
        apt update
    fi

    # Install latest PHP and extensions (no version hardcode)
    apt install -y php php-fpm php-cli php-common php-pgsql php-zip php-gd php-mbstring php-curl php-xml php-bcmath php-intl

    # Detect PHP-FPM service name
    PHP_FPM_SERVICE=$(systemctl list-units --type=service | grep -o 'php[0-9.]*-fpm' | head -n1)
    if [ -z "$PHP_FPM_SERVICE" ]; then
        print_error "PHP-FPM service not found after install!"
        exit 1
    fi
    systemctl start $PHP_FPM_SERVICE
    systemctl enable $PHP_FPM_SERVICE

    # Install Composer
    if ! command_exists composer; then
        print_status "Installing Composer..."
        curl -sS https://getcomposer.org/installer | php
        mv composer.phar /usr/local/bin/composer
        chmod +x /usr/local/bin/composer
    else
        print_success "Composer already installed"
    fi

    # Install PostgreSQL
    if ! command_exists psql; then
        print_status "Installing PostgreSQL..."
        apt install -y postgresql postgresql-contrib
        systemctl enable postgresql
        systemctl start postgresql
    else
        print_success "PostgreSQL already installed"
    fi

    # Install Nginx
    if ! command_exists nginx; then
        print_status "Installing Nginx..."
        apt install nginx -y
        systemctl enable nginx
        systemctl start nginx
    else
        print_success "Nginx already installed"
    fi

    # Install Certbot
    if ! command_exists certbot; then
        print_status "Installing Certbot..."
        apt install certbot python3-certbot-nginx -y
    else
        print_success "Certbot already installed"
    fi

    # Install Node.js and npm (for frontend assets)
    # if ! command_exists node; then
    #     print_status "Installing Node.js..."
    #     curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    #     apt install -y nodejs
    # else
    #     print_success "Node.js already installed"
    # fi

    print_success "All required software installed"
}

# Function to clone repository
declare -A BRANCH_TRY_ORDER
BRANCH_TRY_ORDER[1]="main"
BRANCH_TRY_ORDER[2]="master"
BRANCH_TRY_ORDER[3]="pupuk"

clone_repository() {
    local repo_url=$1
    local branch=$2
    local project_dir=$3

    print_status "Cloning repository..."

    # Remove existing directory if exists
    if [ -d "$project_dir" ]; then
        print_warning "Directory $project_dir already exists. Removing..."
        rm -rf "$project_dir"
    fi

    # Clone repository with specific branch
    if [ -n "$branch" ]; then
        git clone -b "$branch" "$repo_url" "$project_dir"
    else
        # Try default branches in order
        for try_branch in "${BRANCH_TRY_ORDER[@]}"; do
            if git ls-remote --heads "$repo_url" "$try_branch" | grep "$try_branch" >/dev/null; then
                print_status "Branch not specified, using detected branch: $try_branch"
                git clone -b "$try_branch" "$repo_url" "$project_dir"
                branch="$try_branch"
                break
            fi
        done
        if [ ! -d "$project_dir" ]; then
            print_error "Could not find a valid branch to clone. Please specify a branch."
            exit 1
        fi
    fi

    # Set ownership
    chown -R www-data:www-data "$project_dir"
    # Set permissions
    chmod -R 755 "$project_dir"
    chmod -R 777 "$project_dir"/storage
    chmod -R 777 "$project_dir"/bootstrap/cache

    print_success "Repository cloned successfully"
}

# Function to check if directory is a Laravel project
is_laravel_project() {
    local dir=$1
    if [ -f "$dir/artisan" ] && [ -f "$dir/.env.example" ] && [ -d "$dir/app" ] && [ -d "$dir/bootstrap" ]; then
        return 0
    else
        return 1
    fi
}

# Function to setup database
setup_database() {
    print_status "Setting up database..."

    # Generate secure password for database
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d '\n')

    # Create database and user
    sudo -u postgres psql -c "CREATE DATABASE laravel_pos;" 2>/dev/null || true
    sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='laravel_pos_app'" | grep -q 1 \
      && sudo -u postgres psql -c "ALTER USER laravel_pos_app WITH PASSWORD '$DB_PASSWORD';" \
      || sudo -u postgres psql -c "CREATE USER laravel_pos_app WITH PASSWORD '$DB_PASSWORD';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE laravel_pos TO laravel_pos_app;"
    sudo -u postgres psql -c "ALTER USER laravel_pos_app CREATEDB;"
    sudo -u postgres psql -d laravel_pos -c "GRANT ALL ON SCHEMA public TO laravel_pos_app;"

    print_success "Database setup completed"
    print_status "Database Password: $DB_PASSWORD"
}

# Function to setup environment
setup_environment() {
    local domain=$1
    local project_dir=$2

    print_status "Setting up environment..."

    # Copy environment file
    cp .env.example .env

    # Update .env with database configuration
    sed -i "s/DB_CONNECTION=.*/DB_CONNECTION=pgsql/" .env
    sed -i "s/DB_HOST=.*/DB_HOST=127.0.0.1/" .env
    sed -i "s/DB_PORT=.*/DB_PORT=5432/" .env
    sed -i "s/DB_DATABASE=.*/DB_DATABASE=laravel_pos/" .env
    sed -i "s/DB_USERNAME=.*/DB_USERNAME=laravel_pos_app/" .env
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=$DB_PASSWORD#" .env

    # Update app configuration
    sed -i "s/APP_URL=.*/APP_URL=https:\/\/$domain/" .env
    sed -i "s/APP_ENV=.*/APP_ENV=production/" .env
    sed -i "s/APP_DEBUG=.*/APP_DEBUG=false/" .env

    # Use file cache instead of Redis
    sed -i "s/CACHE_DRIVER=.*/CACHE_DRIVER=file/" .env
    sed -i "s/SESSION_DRIVER=.*/SESSION_DRIVER=file/" .env
    sed -i "s/QUEUE_CONNECTION=.*/QUEUE_CONNECTION=sync/" .env

    # Set proper permissions
    chown www-data:www-data .env
    chmod 600 .env

    print_success "Environment configured"
}

# Function to setup Laravel
setup_laravel() {
    local project_dir=$1
    cd "$project_dir"
    print_status "Setting up Laravel application..."

    # Install dependencies
    # sudo -u www-data composer install --no-dev --optimize-autoloader
    sudo -u www-data composer install --optimize-autoloader
    sudo -u www-data composer update --no-interaction

    # Generate application key
    sudo -u www-data php artisan key:generate

    # Run migrations and seeders
    sudo -u www-data php artisan migrate:fresh --seed --force

    # Setup Shield
    # echo "y" | sudo -u www-data php artisan shield:setup --fresh

    # Install Shield admin
    # sudo -u www-data php artisan shield:install admin

    # Create super admin user
    # sudo -u www-data php artisan shield:super-admin --user=2

    # Optimize Laravel
    sudo -u www-data php artisan optimize
    sudo -u www-data php artisan config:cache
    sudo -u www-data php artisan route:cache
    sudo -u www-data php artisan view:cache

    # Create storage link
    sudo -u www-data php artisan storage:link

    print_success "Laravel setup completed"
}

# Function to setup Nginx
setup_nginx() {
    local domain=$1
    local project_dir=$2
    local repo_name=$3

    print_status "Setting up Nginx..."

    # Create Nginx configuration
    cat > /etc/nginx/sites-available/$repo_name << EOF
limit_req_zone \$binary_remote_addr zone=api:10m rate=100r/s;
server {
    listen 80;
    server_name $domain www.$domain;
    root $project_dir/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    # Handle Laravel routes
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    # Handle PHP files
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/$PHP_FPM_SERVICE.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }

    # Deny access to bootstrap/cache
    location ~ ^/bootstrap/cache/ {
        deny all;
    }

    # Handle large file uploads
    client_max_body_size 50M;

    # Rate limiting for /api/
    location /api/ {
        limit_req zone=api burst=200 nodelay;
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
}
EOF

    # Enable the site
    ln -sf /etc/nginx/sites-available/$repo_name /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default

    # Test Nginx configuration
    nginx -t

    # Reload Nginx
    systemctl reload nginx

    print_success "Nginx configured"
}

# Function to setup SSL
setup_ssl() {
    local domain=$1
    local email=$2

    print_status "Setting up SSL certificate..."

    # Install Certbot via Snap (best practice)
    if ! command_exists snap; then
        print_status "Installing snapd..."
        apt install -y snapd
    fi
    sudo snap install core; sudo snap refresh core
    sudo apt remove -y certbot || true
    sudo snap install --classic certbot
    sudo ln -sf /snap/bin/certbot /usr/bin/certbot

    # Setup UFW rules for HTTPS
    if command_exists ufw; then
        sudo ufw allow 'OpenSSH'
        sudo ufw allow 'Nginx Full'
        sudo ufw delete allow 'Nginx HTTP' || true
        sudo ufw --force enable
    fi

    # Get SSL certificate (with and without www)
    certbot --nginx -d "$domain" -d "www.$domain" --non-interactive --agree-tos --email "$email"

    print_success "SSL certificate configured"
}

# Function to verify deployment
verify_deployment() {
    local domain=$1

    print_status "Verifying deployment..."

    # Check if Nginx is running
    if systemctl is-active --quiet nginx; then
        print_success "Nginx is running"
    else
        print_error "Nginx is not running"
        return 1
    fi

    # Check if PHP-FPM is running
    if systemctl is-active --quiet $PHP_FPM_SERVICE; then
        print_success "PHP-FPM is running"
    else
        print_error "PHP-FPM is not running"
        return 1
    fi

    # Test website accessibility
    if curl -s -o /dev/null -w "%{http_code}" "https://$domain" | grep -q "200"; then
        print_success "Website is accessible"
    else
        print_warning "Website might not be accessible yet (DNS propagation)"
    fi

    print_success "Deployment verification completed"
}

# Function to show final information
show_final_info() {
    local domain=$1
    local db_password=$2

    echo ""
    echo "=========================================="
    echo "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉"
    echo "=========================================="
    echo ""
    echo "Your Laravel POS application is now live at:"
    echo "🌐 Main site: https://$domain"
    echo "🔧 Admin panel: https://$domain/admin"
    echo ""
    echo "Important files and locations:"
    echo "📁 Application: $project_dir"
    echo "⚙️  Nginx config: /etc/nginx/sites-available/$repo_name"
    echo "🗄️  Database: PostgreSQL (localhost)"
    echo ""
    echo "Useful commands:"
    echo "📊 Check Nginx status: systemctl status nginx"
    echo "📊 Check PHP-FPM status: systemctl status $PHP_FPM_SERVICE"
    echo "📝 View Nginx logs: tail -f /var/log/nginx/error.log"
    echo "🔄 Restart services: systemctl restart nginx $PHP_FPM_SERVICE"
    echo "🔒 SSL renewal: certbot renew"
    echo ""
    echo "Security features enabled:"
    echo "✅ Secure database user"
    echo "✅ Nginx rate limiting (100 req/s)"
    echo "✅ SSL certificate"
    echo "✅ File upload limit (50MB)"
    echo "✅ Hidden file protection"
    echo ""
    echo "IMPORTANT: Database credentials (save these securely!):"
    echo "📋 Database Password: $db_password"
    echo "📋 Or check the .env file in $project_dir"
    echo ""
    echo "Next steps:"
    echo "1. Create admin user in Filament panel"
    echo "2. Configure your business settings"
    echo "3. Set up regular backups"
    echo "4. Monitor application logs"
    echo ""
    echo "For support, check the documentation:"
    echo "📚 VPS-SETUP.md"
    echo "📚 QUICK-SETUP.md"
    echo ""
}

# Main deployment function
main() {
    local repo_url=$1
    local branch=$2
    local domain=$3
    local email=$4

    if [ -z "$repo_url" ] || [ -z "$domain" ] || [ -z "$email" ]; then
        echo "Usage: sudo ./deploy-laravel.sh <repo_url> [branch] <domain> <email>"
        echo "Example: sudo ./deploy-laravel.sh https://github.com/laravel/laravel.git main example.com admin@example.com"
        echo "Branch is optional. If not specified, will try: main, master, pupuk."
        exit 1
    fi

    # If branch is not specified, shift args so domain/email are correct
    if [[ "$branch" != "" && "$branch" != "main" && "$branch" != "master" && "$branch" != "pupuk" && "$branch" != "develop" && "$branch" != "dev" ]]; then
        # branch is actually domain
        email=$3
        domain=$2
        branch=""
    fi

    # Validate domain format
    if ! validate_domain "$domain"; then
        print_error "Invalid domain format: $domain"
        echo "Please use a valid domain name (e.g., example.com)"
        exit 1
    fi

    # Validate email format
    if ! validate_email "$email"; then
        print_error "Invalid email format: $email"
        echo "Please use a valid email address (e.g., admin@example.com)"
        exit 1
    fi

    # Parse repo name from URL
    repo_name=$(basename -s .git "$repo_url")
    project_dir="/var/www/$repo_name"

    # Clean up any old setup files in current dir
    cleanup_old_files

    # --- AUTO CLONE ---
    clone_repository "$repo_url" "$branch" "$project_dir"

    # Check if valid Laravel project
    if ! is_laravel_project "$project_dir"; then
        print_error "The repository at $repo_url is not a valid Laravel project. Aborting."
        rm -rf "$project_dir"
        exit 1
    fi

    cd "$project_dir"
    cleanup_old_files
    verify_environment

    echo "=========================================="
    echo "🚀 Generic Laravel Deployment Script"
    echo "=========================================="
    echo ""
    echo "Repository: $repo_url"
    echo "Branch: $branch"
    echo "Domain: $domain"
    echo "Email: $email"
    echo "Project Directory: $project_dir"
    echo ""
    echo "=========================================="
    echo "📋 DEPLOYMENT SUMMARY"
    echo "=========================================="
    echo "Repository: $repo_url"
    echo "Branch: $branch"
    echo "Domain: $domain"
    echo "Email: $email"
    echo "Installation Path: $project_dir"
    echo ""
    echo "This will:"
    echo "✅ Install PHP, PostgreSQL, Nginx, and Certbot"
    echo "✅ Clone the Laravel repository"
    echo "✅ Setup database and user"
    echo "✅ Configure Laravel application"
    echo "✅ Setup Nginx web server"
    echo "✅ Setup SSL certificate"
    echo ""
    read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Deployment cancelled"
        exit 0
    fi
    check_root
    print_status "Starting deployment process..."
    install_software
    setup_database
    setup_environment "$domain" "$project_dir"
    setup_laravel "$project_dir"
    setup_nginx "$domain" "$project_dir" "$repo_name"
    setup_ssl "$domain" "$email"
    verify_deployment "$domain"
    show_final_info "$domain" "$DB_PASSWORD"
    print_success "Deployment completed successfully!"
}

main "$@"
