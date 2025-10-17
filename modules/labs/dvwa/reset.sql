CREATE DATABASE IF NOT EXISTS dvwa;
USE dvwa;

-- Supprime si existe déjà
DROP TABLE IF EXISTS users;

-- Crée la table users
CREATE TABLE users (
  user_id int(6) NOT NULL auto_increment,
  first_name varchar(15) NOT NULL,
  last_name varchar(15) NOT NULL,
  user varchar(15) NOT NULL,
  password varchar(32) NOT NULL,
  avatar varchar(70) NOT NULL,
  last_login TIMESTAMP,
  failed_login INT(3) DEFAULT '0',
  PRIMARY KEY (user_id)
);

-- Insère l’admin par défaut
INSERT INTO users VALUES (
  1, 'admin', 'admin', 'admin', MD5('password'),
  'dvwa/hackable/users/admin.jpg', NOW(), 0
);
