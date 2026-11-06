-- =========================================================================
-- Pocket Database Schema
-- Description: Core database architecture for tracking personal possessions
-- across distributed storage locations, supporting multi-user inventory groups.
-- =========================================================================

CREATE DATABASE IF NOT EXISTS pocket_db;
USE pocket_db;

-- 1. Users Table
-- Stores individual system users who can log into the application.
CREATE TABLE IF NOT EXISTS user (
    user_id INT AUTO_INCREMENT PRIMARY KEY,          -- Unique identifier for the user
    email VARCHAR(100) NOT NULL UNIQUE,              -- User login email address (must be unique)
    name VARCHAR(100) NOT NULL                       -- Full display name of the user
);

-- 2. Inventory Groups Table
-- Represents shared asset groups (e.g., families, roommates, or team projects).
CREATE TABLE IF NOT EXISTS inventory_group (
    group_id INT AUTO_INCREMENT PRIMARY KEY,         -- Unique identifier for the inventory group
    group_name VARCHAR(100) NOT NULL                 -- Name of the shared group or household
);

-- 3. Group Members Table
-- Junction table mapping users to inventory groups with role-based access.
CREATE TABLE IF NOT EXISTS group_member (
    user_id INT,                                     -- Foreign key referencing the user
    group_id INT,                                    -- Foreign key referencing the inventory group
    role VARCHAR(50) NOT NULL,                       -- Member role (e.g., Admin, Member)
    PRIMARY KEY (user_id, group_id),                 -- Composite primary key enforcing unique user-group pairs
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES inventory_group(group_id) ON DELETE CASCADE
);

-- 4. Primary Locations Table
-- Top-level storage venues belonging to an inventory group (e.g., "Home", "Storage Unit").
CREATE TABLE IF NOT EXISTS primary_location (
    loc_id INT AUTO_INCREMENT PRIMARY KEY,           -- Unique identifier for the primary location
    group_id INT NOT NULL,                           -- Foreign key linking location to an inventory group
    name VARCHAR(100) NOT NULL,                      -- Name of the primary location
    FOREIGN KEY (group_id) REFERENCES inventory_group(group_id) ON DELETE CASCADE
);

-- 5. Sublocations Table
-- Granular storage areas within a primary location (e.g., "Garage Workbench", "Shelf 3").
CREATE TABLE IF NOT EXISTS sublocation (
    sub_id INT AUTO_INCREMENT PRIMARY KEY,           -- Unique identifier for the sublocation
    loc_id INT NOT NULL,                             -- Foreign key linking to the parent primary location
    name VARCHAR(100) NOT NULL,                      -- Name of the sublocation
    FOREIGN KEY (loc_id) REFERENCES primary_location(loc_id) ON DELETE CASCADE
);

-- 6. Categories Table
-- User-defined classifications or tags for organizing inventory items.
CREATE TABLE IF NOT EXISTS category (
    cat_id INT AUTO_INCREMENT PRIMARY KEY,           -- Unique identifier for the category
    group_id INT NOT NULL,                           -- Foreign key linking category to an inventory group
    name VARCHAR(50) NOT NULL,                       -- Category label (e.g., Tools, Electronics)
    FOREIGN KEY (group_id) REFERENCES inventory_group(group_id) ON DELETE CASCADE
);

-- 7. Items Table
-- The core inventory asset entity linked to specific locations and sublocations.
CREATE TABLE IF NOT EXISTS item (
    item_id INT AUTO_INCREMENT PRIMARY KEY,          -- Unique identifier for the inventory item
    loc_id INT NOT NULL,                             -- Foreign key referencing the primary location
    sub_id INT DEFAULT NULL,                         -- Optional foreign key referencing a specific sublocation
    name VARCHAR(100) NOT NULL,                      -- Name of the item
    description TEXT,                                -- Detailed description or notes about the item
    image_url VARCHAR(255),                          -- File path or URL to an image of the item
    FOREIGN KEY (loc_id) REFERENCES primary_location(loc_id) ON DELETE CASCADE,
    FOREIGN KEY (sub_id) REFERENCES sublocation(sub_id) ON DELETE SET NULL
);

-- 8. Item-Category Bridge Table
-- Many-to-many relationship mapping items to multiple categories.
CREATE TABLE IF NOT EXISTS item_category (
    item_id INT,                                     -- Foreign key referencing the item
    cat_id INT,                                      -- Foreign key referencing the category
    PRIMARY KEY (item_id, cat_id),                   -- Composite primary key ensuring unique item-category mappings
    FOREIGN KEY (item_id) REFERENCES item(item_id) ON DELETE CASCADE,
    FOREIGN KEY (cat_id) REFERENCES category(cat_id) ON DELETE CASCADE
);