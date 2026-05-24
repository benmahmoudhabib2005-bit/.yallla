# YallaWork PHP + MySQL

## Installation
1. Copy this folder into your local server folder:
   - XAMPP: `htdocs/yallawork_php_mysql`
   - WAMP: `www/yallawork_php_mysql`
2. Open phpMyAdmin and import `database.sql`.
3. Edit `php/config.php` if your MySQL username/password are different.
4. Start Apache and MySQL.
5. Open: `http://localhost/yallawork_php_mysql/`

## Files
- `index.html` — frontend markup
- `styles.css` — CSS
- `script.js` — JavaScript connected to PHP endpoints
- `database.sql` — MySQL database and sample data
- `php/config.php` — PDO MySQL connection
- `php/register.php` — create account
- `php/login.php` — login
- `php/search_offers.php` — search offers
- `php/apply.php` — submit application + CV upload
- `php/send_message.php` — save messages
