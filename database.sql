-- ============================================================
-- YallaWork Database — Enhanced Schema with Account Management
-- ============================================================

CREATE DATABASE IF NOT EXISTS yallawork
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE yallawork;

-- ------------------------------------------------------------
-- 1. users / accounts
-- Stores login accounts securely.
-- IMPORTANT: never store plain passwords; store PHP password_hash().
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  prenom           VARCHAR(100) NOT NULL,
  nom              VARCHAR(100) NOT NULL,
  username         VARCHAR(80)  NULL UNIQUE,
  email            VARCHAR(190) NOT NULL UNIQUE,
  phone            VARCHAR(30)  NULL,
  password_hash    VARCHAR(255) NOT NULL,
  role             ENUM('etudiant','entreprise','admin') NOT NULL DEFAULT 'etudiant',
  account_status   ENUM('active','pending','blocked','deleted') NOT NULL DEFAULT 'active',
  email_verified   TINYINT(1) NOT NULL DEFAULT 0,
  last_login_at    DATETIME NULL,
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_users_email (email),
  INDEX idx_users_role (role),
  INDEX idx_users_status (account_status)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. account_profiles
-- Extra profile data separated from login data.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS account_profiles (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id     INT UNSIGNED NOT NULL UNIQUE,
  avatar_path VARCHAR(255) NULL,
  bio         TEXT NULL,
  ville       VARCHAR(100) NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_profile_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3. password_resets
-- For forgotten-password tokens.
-- Store only a hashed token, not the raw token.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS password_resets (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id     INT UNSIGNED NOT NULL,
  token_hash  VARCHAR(255) NOT NULL,
  expires_at  DATETIME NOT NULL,
  used_at     DATETIME NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_reset_user (user_id),
  INDEX idx_reset_expires (expires_at),

  CONSTRAINT fk_reset_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. user_sessions
-- Optional: save remember-me sessions or active login sessions.
-- Store only a hashed session token.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_sessions (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id     INT UNSIGNED NOT NULL,
  token_hash  VARCHAR(255) NOT NULL UNIQUE,
  ip_address  VARCHAR(45) NULL,
  user_agent  VARCHAR(255) NULL,
  expires_at  DATETIME NOT NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_session_user (user_id),
  INDEX idx_session_expires (expires_at),

  CONSTRAINT fk_session_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 5. offers
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS offers (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  posted_by     INT UNSIGNED NULL,
  titre         VARCHAR(190) NOT NULL,
  entreprise    VARCHAR(190) NOT NULL,
  type_contrat  VARCHAR(50) NOT NULL,
  ville         VARCHAR(100) NOT NULL,
  salaire       VARCHAR(100) NULL,
  logo          VARCHAR(255) DEFAULT '💼',
  description   TEXT NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_offers_posted_by (posted_by),
  INDEX idx_offers_ville (ville),
  INDEX idx_offers_type (type_contrat),

  CONSTRAINT fk_offer_user
    FOREIGN KEY (posted_by) REFERENCES users(id)
    ON DELETE SET NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 6. applications
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS applications (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  offer_id    INT UNSIGNED NULL,
  user_id     INT UNSIGNED NULL,
  prenom      VARCHAR(100) NOT NULL,
  nom         VARCHAR(100) NOT NULL,
  email       VARCHAR(190) NOT NULL,
  lettre      TEXT NULL,
  cv_path     VARCHAR(255) NULL,
  status      ENUM('envoyee','vue','entretien','acceptee','refusee') DEFAULT 'envoyee',
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_app_offer (offer_id),
  INDEX idx_app_user (user_id),
  INDEX idx_app_status (status),

  CONSTRAINT fk_app_offer
    FOREIGN KEY (offer_id) REFERENCES offers(id)
    ON DELETE SET NULL,

  CONSTRAINT fk_app_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE SET NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 7. messages
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS messages (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sender_id   INT UNSIGNED NULL,
  receiver_id INT UNSIGNED NULL,
  body        TEXT NOT NULL,
  is_read     TINYINT(1) NOT NULL DEFAULT 0,
  read_at     TIMESTAMP NULL DEFAULT NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_msg_sender (sender_id),
  INDEX idx_msg_receiver (receiver_id),
  INDEX idx_msg_read (is_read),

  CONSTRAINT fk_msg_sender
    FOREIGN KEY (sender_id) REFERENCES users(id)
    ON DELETE SET NULL,

  CONSTRAINT fk_msg_receiver
    FOREIGN KEY (receiver_id) REFERENCES users(id)
    ON DELETE SET NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Sample admin account
-- Replace this hash with one generated by PHP password_hash().
-- Example PHP:
-- echo password_hash('Admin12345!', PASSWORD_DEFAULT);
-- ------------------------------------------------------------
INSERT INTO users (prenom, nom, username, email, password_hash, role, account_status, email_verified)
VALUES ('Admin', 'YallaWork', 'admin', 'admin@yallawork.local', '$2y$10$replace_this_hash_with_password_hash', 'admin', 'active', 1)
ON DUPLICATE KEY UPDATE email = email;

-- ------------------------------------------------------------
-- Sample offers
-- ------------------------------------------------------------
INSERT INTO offers (titre, entreprise, type_contrat, ville, salaire, logo, description) VALUES
('Développeur Full-Stack Junior', 'FinTech Maghreb S.A.', 'CDI', 'Tunis', '2 800 – 3 500 TND', '🏦', 'React, PHP, MySQL'),
('Stage Data Science – Analyse Comportementale', 'E-Commerce Solutions', 'Stage', 'Sfax', '600 TND/mois', '🛒', 'Python, SQL, ML'),
('UX/UI Designer – Applications Mobile', 'Agence Pixel & Co', 'CDD', 'Sousse', '1 800 TND', '🎨', 'Figma, prototypage'),
('Alternance – Cybersécurité & Audit SI', 'NordTech Consulting', 'Alternance', 'Ariana', '900 TND/mois', '🔬', 'Sécurité, audit SI');
