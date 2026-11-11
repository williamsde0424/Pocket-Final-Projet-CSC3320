-- =========================================================================
-- Pocket Database Schema & Query Definitions
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
    name VARCHAR(100) NOT NULL,                      -- Full display name of the user
    password_hash VARCHAR(255) NOT NULL              -- Hashing for password authentication     
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


-- =========================================================================
-- Non-Trivial Query Demonstrations (Project Requirements)
-- =========================================================================

-- Query 1: Multi-Table Hierarchy Join
-- Purpose: Retrieves all inventory items along with their full storage hierarchy 
-- (Primary Location, optional Sublocation, and parent Inventory Group). 
-- Uses an outer join for sublocations since sublocations are optional.
SELECT i.item_id, i.name AS item_name, pl.name AS primary_location, s.name AS sublocation, ig.group_name
FROM item i
JOIN primary_location pl ON i.loc_id = pl.loc_id
LEFT JOIN sublocation s ON i.sub_id = s.sub_id
JOIN inventory_group ig ON pl.group_id = ig.group_id;


-- Query 2: Aggregation and Grouping
-- Purpose: Calculates the total count of inventory items stored within each primary 
-- location. Uses a LEFT JOIN to ensure locations with zero items are still displayed.
SELECT pl.name AS primary_location, COUNT(i.item_id) AS total_items
FROM primary_location pl
LEFT JOIN item i ON pl.loc_id = i.loc_id
GROUP BY pl.loc_id, pl.name;


-- Query 3: Many-to-Many Filtering
-- Purpose: Filters and retrieves all items belonging to a specific category label 
-- ('Tools') within a specific inventory group (group_id = 1) by traversing 
-- the item_category bridge table.
SELECT i.name, i.description
FROM item i
JOIN item_category ic ON i.item_id = ic.item_id
JOIN category c ON ic.cat_id = c.cat_id
WHERE c.name = 'Tools' AND c.group_id = 1;


-- Query 4: Correlated Subquery / Threshold Filter
-- Purpose: Identifies inventory groups that manage a high volume of assets by 
-- returning groups that currently contain strictly more than 5 total items across 
-- their primary locations.
SELECT ig.group_id, ig.group_name
FROM inventory_group ig
WHERE (
    SELECT COUNT(*) 
    FROM primary_location pl 
    JOIN item i ON pl.loc_id = i.loc_id 
    WHERE pl.group_id = ig.group_id
) > 5;


-- Query 5: Group Membership & Role Lookup
-- Purpose: Queries the group_member junction table to list all users assigned to a 
-- specific inventory group (group_id = 1), including their security access role 
-- (e.g., Admin or Member).
SELECT u.name AS user_name, u.email, gm.role
FROM user u
JOIN group_member gm ON u.user_id = gm.user_id
WHERE gm.group_id = 1;