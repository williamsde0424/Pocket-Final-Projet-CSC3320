# Pocket-Final-Projet-CSC3320

Final project Database for CSC3320

# Pocket - Personal Possession & Inventory Tracker

**CSC 3320 Database Systems Final Project**  
**Team 2:** Demarion Williams, Dominic Celentano, Lexi Dorner  
**Institution:** Milwaukee School of Engineering (MSOE)

---

## Project Overview

**Pocket** is a cross-platform web and mobile application designed to track and organize personal possessions across distributed storage locations (such as multiple residences, dorm rooms, or storage units). The system supports multi-user inventory groups, sublocation hierarchies, category tagging, and rapid item lookups.

---

## Tech Stack

* **Database:** MySQL (`pocket_db`) with relational constraints and foreign key cascading.
* **Backend:** Python (`mysql-connector-python`), with planned Node.js / Express REST API integration.
* **Frontend:** React (Web) and React Native / PWA (Mobile).
* **Version Control:** Git & GitHub

---

## Database Schema (`schema.sql`)

The relational schema comprises 8 core tables:

1. `user`: Stores system users.
2. `inventory_group`: Represents shared asset groups (e.g., families, roommates, business).
3. `group_member`: Junction table mapping users to inventory groups with role-based access.
4. `primary_location`: Top-level storage venues (e.g., "Home", "Storage Unit").
5. `sublocation`: Granular storage areas (e.g., "Garage Workbench", "Shelf 3").
6. `category`: User-defined item classifications.
7. `item`: The core inventory asset entity linked to locations and sublocations.
8. `item_category`: Many-to-many bridge linking items to categories.

---

## Setup Instructions

1. Clone the repository and navigate to the project directory.
2. Run the database initialization script to create `pocket_db` and all tables:

   ```powershell
   python init_db.py
