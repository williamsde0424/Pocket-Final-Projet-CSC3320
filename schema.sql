CREATE DATABASE IF NOT EXISTS pocket_db;
USE pocket_db;

CREATE TABLE IF NOT EXISTS user (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS inventory_group (
    group_id INT AUTO_INCREMENT PRIMARY KEY,
    group_name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS group_member (
    user_id INT,
    group_id INT,
    role VARCHAR(50) NOT NULL,
    PRIMARY KEY (user_id, group_id),
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES inventory_group(group_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS primary_location (
    loc_id INT AUTO_INCREMENT PRIMARY KEY,
    group_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    FOREIGN KEY (group_id) REFERENCES inventory_group(group_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS sublocation (
    sub_id INT AUTO_INCREMENT PRIMARY KEY,
    loc_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    FOREIGN KEY (loc_id) REFERENCES primary_location(loc_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS category (
    cat_id INT AUTO_INCREMENT PRIMARY KEY,
    group_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    FOREIGN KEY (group_id) REFERENCES inventory_group(group_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS item (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    loc_id INT NOT NULL,
    sub_id INT DEFAULT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    FOREIGN KEY (loc_id) REFERENCES primary_location(loc_id) ON DELETE CASCADE,
    FOREIGN KEY (sub_id) REFERENCES sublocation(sub_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS item_category (
    item_id INT,
    cat_id INT,
    PRIMARY KEY (item_id, cat_id),
    FOREIGN KEY (item_id) REFERENCES item(item_id) ON DELETE CASCADE,
    FOREIGN KEY (cat_id) REFERENCES category(cat_id) ON DELETE CASCADE
);
