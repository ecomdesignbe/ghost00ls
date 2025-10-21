<?php

# Database management system to use
$DBMS = getenv('DBMS') ?: 'MySQL';

# Database variables
$_DVWA = array();
$_DVWA['db_server']   = 'dvwa-db';
$_DVWA['db_database'] = 'dvwa';
$_DVWA['db_user']     = 'dvwa';
$_DVWA['db_password'] = 'p@ssw0rd';
$_DVWA['db_port']     = '3306';

# ReCAPTCHA settings
$_DVWA['recaptcha_public_key']  = getenv('RECAPTCHA_PUBLIC_KEY') ?: '';
$_DVWA['recaptcha_private_key'] = getenv('RECAPTCHA_PRIVATE_KEY') ?: '';

# Default security level
$_DVWA['default_security_level'] = getenv('DEFAULT_SECURITY_LEVEL') ?: 'low';

# Default locale
$_DVWA['default_locale'] = getenv('DEFAULT_LOCALE') ?: 'en';

# Disable authentication
$_DVWA['disable_authentication'] = getenv('DISABLE_AUTHENTICATION') ?: false;

# SQLi DB Backend
$_DVWA['SQLI_DB'] = getenv('SQLI_DB') ?: 'MySQL';

# Define constants (À LA FIN !)
define('MYSQL', 'MySQL');
define('SQLITE', 'sqlite');

?>
