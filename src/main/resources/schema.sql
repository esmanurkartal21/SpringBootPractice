-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema securecapita
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `securecapita` DEFAULT CHARACTER SET utf8 ;
USE `securecapita` ;

-- -----------------------------------------------------
-- Table `securecapita`.`Users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `securecapita`.`Users` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `password` VARCHAR(255) NULL DEFAULT NULL,
  `address` VARCHAR(255) NULL DEFAULT NULL,
  `phone` VARCHAR(30) NULL DEFAULT NULL,
  `title` VARCHAR(50) NULL DEFAULT NULL,
  `bio` VARCHAR(255) NULL DEFAULT NULL,
  `enabled` BOOLEAN DEFAULT FALSE,
  `non_locked` BOOLEAN DEFAULT TRUE,
  `using_mfa` BOOLEAN DEFAULT FALSE,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `image_url` VARCHAR(255) DEFAULT 'https://preview.redd.it/zmp0wyobsx991.png?width=370&format=png&auto=webp&s=e594491ef5204ea40ff4133c279745d5aab75dba',
  PRIMARY KEY (`id`),
  CONSTRAINT `UQ_Users_Email` UNIQUE (`email`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `securecapita`.`Roles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `securecapita`.`Roles` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `permission` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `UQ_Roles_Name` UNIQUE (`name`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `securecapita`.`UserRoles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `securecapita`.`UserRoles` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `role_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_UserRoles_Users_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_UserRoles_Roles1_idx` (`role_id` ASC) VISIBLE,
  CONSTRAINT `fk_UserRoles_Users`
    FOREIGN KEY (`user_id`)
    REFERENCES `securecapita`.`Users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_UserRoles_Roles1`
    FOREIGN KEY (`role_id`)
    REFERENCES `securecapita`.`Roles` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `securecapita`.`Events`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `securecapita`.`Events` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `type` VARCHAR(50) NOT NULL CHECK(type IN ('LOGIN_ATTEMPT', 'LOGIN_ATTEMPT_FAILURE', 'LOGIN_ATTEMPT_SUCCESS', 'PROFILE_UPDATE', 'PROFILE_PICTURE_UPDATE', 'ROLE_UPDATE', 'ACCOUNT_SETTINGS_UPDATE', 'PASSWORD_UPDATE', 'MFA_UPDATE')),
  `description` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `UQ_Events_Type` UNIQUE (`type`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `securecapita`.`UserEvents`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `securecapita`.`UserEvents` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `event_id` BIGINT NOT NULL,
  `device` VARCHAR(100) NULL DEFAULT NULL,
  `ip_address` VARCHAR(100) NULL DEFAULT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_UserEvents_Users_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_UserEvents_Events1_idx` (`event_id` ASC) VISIBLE,
  CONSTRAINT `fk_UserEvents_Users`
    FOREIGN KEY (`user_id`)
    REFERENCES `securecapita`.`Users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_UserEvents_Events1`
    FOREIGN KEY (`event_id`)
    REFERENCES `securecapita`.`Events` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `securecapita`.`AccountVerifications`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `securecapita`.`AccountVerifications` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `url` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_AccountVerifications_Users_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_AccountVerifications_Users`
    FOREIGN KEY (`user_id`)
    REFERENCES `securecapita`.`Users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `UQ_AccountVerifications_User_Id` UNIQUE (`user_id`),
  CONSTRAINT `UQ_AccountVerifications_Url` UNIQUE (`url`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `securecapita`.`ResetPasswordVerifications`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `securecapita`.`ResetPasswordVerifications` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `url` VARCHAR(255) NOT NULL,
  `expiration_date` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_ResetPasswordVerifications_Users_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_ResetPasswordVerifications_Users`
    FOREIGN KEY (`user_id`)
    REFERENCES `securecapita`.`Users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `UQ_ResetPasswordVerifications_User_Id` UNIQUE (`user_id`),
  CONSTRAINT `UQ_ResetPasswordVerifications_Url` UNIQUE (`url`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `securecapita`.`TwoFactorVerifications`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `securecapita`.`TwoFactorVerifications` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `code` VARCHAR(10) NOT NULL,
  `expiration_date` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_TwoFactorVerifications_Users_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_TwoFactorVerifications_Users`
    FOREIGN KEY (`user_id`)
    REFERENCES `securecapita`.`Users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `UQ_TwoFactorVerifications_User_Id` UNIQUE (`user_id`),
  CONSTRAINT `UQ_TwoFactorVerifications_Code` UNIQUE (`code`))
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
