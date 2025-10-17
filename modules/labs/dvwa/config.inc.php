<?php
# Database management system to use
$DBMS = 'MySQL';  // 👈 obligatoire sinon erreur dans dvwaPage.inc.php

# Database variables
$_DVWA['db_server']   = 'dvwa-db';
$_DVWA['db_database'] = 'dvwa';
$_DVWA['db_user']     = 'dvwa';
$_DVWA['db_password'] = 'p@ssw0rd';
$_DVWA['db_port']     = '3306';

# ReCAPTCHA settings
$_DVWA['recaptcha_public_key']  = '';
$_DVWA['recaptcha_private_key'] = '';

# Default security level
$_DVWA['default_security_level'] = 'low';

# Default locale
$_DVWA['default_locale'] = 'en';

# SQLi DB Backend
# Default to MySQL
$_DVWA['SQLI_DB'] = 'MySQL';  

# Define backends explicitly
define('MYSQL', 'MySQL');
define('SQLITE', 'sqlite');
?>
