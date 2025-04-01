-- ResAds Database Schema with Seed Data
-- A comprehensive database for the restaurant marketing platform

-- Drop existing tables if they exist
DROP TABLE IF EXISTS campaign_platform_metrics;
DROP TABLE IF EXISTS campaign_conversions;
DROP TABLE IF EXISTS campaign_metrics;
DROP TABLE IF EXISTS platform_metrics;
DROP TABLE IF EXISTS platform_settings;
DROP TABLE IF EXISTS platforms;
DROP TABLE IF EXISTS campaigns;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS users;

-- Create users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'owner',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    last_login TIMESTAMP
);

-- Create restaurants table
CREATE TABLE restaurants (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    cuisine_type VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip VARCHAR(20) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    website VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create customers table
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    restaurant_id INTEGER REFERENCES restaurants(id),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    address VARCHAR(255),
    city VARCHAR(100),
    zip VARCHAR(20),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    last_order_date TIMESTAMP,
    order_count INTEGER NOT NULL DEFAULT 0,
    total_spent DECIMAL(10, 2) NOT NULL DEFAULT 0.00
);

-- Create campaigns table
CREATE TABLE campaigns (
    id SERIAL PRIMARY KEY,
    restaurant_id INTEGER REFERENCES restaurants(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'draft', -- draft, active, paused, completed
    budget DECIMAL(10, 2) NOT NULL,
    spent DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create platforms table
CREATE TABLE platforms (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL, -- social, search, display, email
    icon VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create platform_settings table
CREATE TABLE platform_settings (
    id SERIAL PRIMARY KEY,
    campaign_id INTEGER REFERENCES campaigns(id),
    platform_id INTEGER REFERENCES platforms(id),
    budget DECIMAL(10, 2) NOT NULL,
    budget_percentage INTEGER NOT NULL,
    ad_format VARCHAR(50) NOT NULL, -- carousel, single_image, video, text, etc.
    audience VARCHAR(50) NOT NULL, -- food_enthusiasts, local_residents, etc.
    bid_strategy VARCHAR(50) NOT NULL DEFAULT 'automatic', -- automatic, manual, target_cpa, etc.
    dayparting BOOLEAN NOT NULL DEFAULT false,
    dayparting_hours VARCHAR(100), -- JSON array of active hours: [12,13,17,18,19,20]
    tracking BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (campaign_id, platform_id)
);

-- Create campaign_metrics table (daily aggregates)
CREATE TABLE campaign_metrics (
    id SERIAL PRIMARY KEY,
    campaign_id INTEGER REFERENCES campaigns(id),
    date DATE NOT NULL,
    impressions INTEGER NOT NULL DEFAULT 0,
    clicks INTEGER NOT NULL DEFAULT 0,
    spend DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    conversions INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (campaign_id, date)
);

-- Create platform_metrics table (daily platform metrics)
CREATE TABLE platform_metrics (
    id SERIAL PRIMARY KEY,
    platform_settings_id INTEGER REFERENCES platform_settings(id),
    date DATE NOT NULL,
    impressions INTEGER NOT NULL DEFAULT 0,
    clicks INTEGER NOT NULL DEFAULT 0,
    spend DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    conversions INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (platform_settings_id, date)
);

-- Create campaign_platform_metrics view for easy querying
CREATE VIEW campaign_platform_metrics AS
SELECT 
    c.id AS campaign_id,
    c.name AS campaign_name,
    p.id AS platform_id,
    p.name AS platform_name,
    p.type AS platform_type,
    ps.budget,
    ps.budget_percentage,
    ps.ad_format,
    pm.date,
    pm.impressions,
    pm.clicks,
    pm.spend,
    pm.conversions
FROM 
    campaigns c
JOIN 
    platform_settings ps ON c.id = ps.campaign_id
JOIN 
    platforms p ON ps.platform_id = p.id
JOIN 
    platform_metrics pm ON ps.id = pm.platform_settings_id;

-- Create campaign_conversions table to track different conversion types
CREATE TABLE campaign_conversions (
    id SERIAL PRIMARY KEY,
    campaign_id INTEGER REFERENCES campaigns(id),
    date DATE NOT NULL,
    type VARCHAR(50) NOT NULL, -- call, direction, order, reservation
    count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (campaign_id, date, type)
);

-- Insert seed data

-- Users
INSERT INTO users (email, password_hash, name, role, created_at, last_login) VALUES
('owner@tacofiesta.com', '$2a$10$hACwQ5/HQI6FhbIISOUVeusy3sKyUDhSq36fF5d/54aULe9V4GimC', 'Maria Rodriguez', 'owner', '2025-01-15', '2025-03-30'),
('owner@pastparadise.com', '$2a$10$hACwQ5/HQI6FhbIISOUVeusy3sKyUDhSq36fF5d/54aULe9V4GimC', 'Marco Bianchi', 'owner', '2025-02-10', '2025-03-29'),
('owner@hometowndiner.com', '$2a$10$hACwQ5/HQI6FhbIISOUVeusy3sKyUDhSq36fF5d/54aULe9V4GimC', 'Sarah Johnson', 'owner', '2025-01-20', '2025-03-28');

-- Restaurants
INSERT INTO restaurants (user_id, name, cuisine_type, address, city, state, zip, phone, website, created_at, updated_at) VALUES
(1, 'Taco Fiesta', 'Mexican', '123 Main St', 'Springfield', 'IL', '62701', '(555) 123-4567', 'https://tacofiesta.example.com', '2025-01-15', '2025-01-15'),
(2, 'Pasta Paradise', 'Italian', '456 Oak Ave', 'Rivertown', 'NY', '10001', '(555) 987-6543', 'https://pastaparadise.example.com', '2025-02-10', '2025-02-10'),
(3, 'Hometown Diner', 'American', '789 Pine St', 'Lakeside', 'CA', '90210', '(555) 456-7890', 'https://hometowndiner.example.com', '2025-01-20', '2025-01-20');

-- Customers (for Taco Fiesta)
INSERT INTO customers (restaurant_id, name, email, phone, address, city, zip, created_at, last_order_date, order_count, total_spent) VALUES
(1, 'Jane Smith', 'jane.smith@example.com', '(555) 123-4567', '123 Main St', 'Springfield', '62701', '2025-02-15', '2025-03-25', 5, 187.45),
(1, 'John Davis', 'john.davis@example.com', '(555) 987-6543', '456 Oak Ave', 'Springfield', '62702', '2025-01-22', '2025-03-20', 3, 124.30),
(1, 'Maria Rodriguez', 'maria.r@example.com', '(555) 456-7890', '789 Pine St', 'Springfield', '62703', '2025-03-05', '2025-03-28', 1, 42.75),
(1, 'Robert Johnson', 'r.johnson@example.com', '(555) 321-9876', '234 Elm St', 'Springfield', '62704', '2025-02-18', '2025-03-15', 2, 83.60),
(1, 'Sarah Williams', 'sarah.w@example.com', '(555) 789-0123', '567 Maple Dr', 'Springfield', '62701', '2025-03-12', NULL, 0, 0.00);

-- Add customers for other restaurants (similar pattern)
INSERT INTO customers (restaurant_id, name, email, phone, address, city, zip, created_at, last_order_date, order_count, total_spent) VALUES
-- Pasta Paradise customers
(2, 'Michael Brown', 'michael.b@example.com', '(555) 234-5678', '789 First Ave', 'Rivertown', '10001', '2025-02-05', '2025-03-27', 4, 215.90),
(2, 'Laura Chen', 'laura.c@example.com', '(555) 345-6789', '123 Second St', 'Rivertown', '10002', '2025-01-10', '2025-03-22', 6, 298.75),
-- Hometown Diner customers
(3, 'David Wilson', 'david.w@example.com', '(555) 456-7890', '456 Beach Rd', 'Lakeside', '90210', '2025-02-20', '2025-03-24', 3, 98.50),
(3, 'Emily Taylor', 'emily.t@example.com', '(555) 567-8901', '789 Ocean Dr', 'Lakeside', '90211', '2025-01-25', '2025-03-18', 5, 142.25);

-- Platforms
INSERT INTO platforms (name, type, icon, created_at) VALUES
('Instagram', 'social', '📸', '2025-01-01'),
('Facebook', 'social', '👥', '2025-01-01'),
('Google', 'search', '🔍', '2025-01-01'),
('Email', 'email', '📧', '2025-01-01'),
('TikTok', 'social', '🎵', '2025-01-01'),
('Local Display', 'display', '🖥️', '2025-01-01');

-- Campaigns for Taco Fiesta
INSERT INTO campaigns (restaurant_id, name, description, status, budget, spent, start_date, end_date, created_at, updated_at) VALUES
(1, 'Weekend Special Promotion', 'Promotion for our weekend family deals with free queso dip', 'active', 1200.00, 487.25, '2025-03-01', '2025-04-15', '2025-02-15', '2025-03-01'),
(1, 'Taco Tuesday', 'Special promotion for Tuesday taco deals', 'active', 800.00, 350.75, '2025-03-15', '2025-04-30', '2025-03-01', '2025-03-15'),
(1, 'Cinco de Mayo Festival', 'Special promotion for Cinco de Mayo celebration', 'scheduled', 1500.00, 0.00, '2025-04-25', '2025-05-10', '2025-03-20', '2025-03-20');

-- Campaigns for Pasta Paradise
INSERT INTO campaigns (restaurant_id, name, description, status, budget, spent, start_date, end_date, created_at, updated_at) VALUES
(2, 'Date Night Special', 'Romantic dinner for two with complimentary wine', 'active', 1000.00, 425.50, '2025-03-10', '2025-04-20', '2025-02-25', '2025-03-10'),
(2, 'Pasta Festival', 'Weekly pasta specials with unlimited breadsticks', 'scheduled', 1200.00, 0.00, '2025-04-15', '2025-05-15', '2025-03-15', '2025-03-15');

-- Campaigns for Hometown Diner
INSERT INTO campaigns (restaurant_id, name, description, status, budget, spent, start_date, end_date, created_at, updated_at) VALUES
(3, 'Breakfast Special', 'Early bird breakfast special with free coffee', 'active', 900.00, 320.25, '2025-03-05', '2025-04-15', '2025-02-20', '2025-03-05'),
(3, 'Weekend Brunch', 'Special weekend brunch menu with mimosas', 'scheduled', 1100.00, 0.00, '2025-04-10', '2025-05-10', '2025-03-25', '2025-03-25');

-- Platform settings for Weekend Special Promotion (Campaign ID: 1)
INSERT INTO platform_settings (campaign_id, platform_id, budget, budget_percentage, ad_format, audience, bid_strategy, dayparting, dayparting_hours, tracking, created_at, updated_at) VALUES
(1, 1, 450.00, 35, 'carousel', 'food_enthusiasts', 'automatic', true, '[12,13,14,17,18,19,20,21]', true, '2025-02-15', '2025-02-15'),  -- Instagram
(1, 2, 300.00, 25, 'carousel', 'local_residents', 'automatic', true, '[11,12,13,14,17,18,19,20]', true, '2025-02-15', '2025-02-15'),  -- Facebook
(1, 3, 350.00, 30, 'text', 'food_enthusiasts', 'manual', false, NULL, true, '2025-02-15', '2025-02-15'),  -- Google
(1, 4, 100.00, 10, 'newsletter', 'existing_customers', 'automatic', false, NULL, true, '2025-02-15', '2025-02-15');  -- Email

-- Platform settings for Taco Tuesday (Campaign ID: 2)
INSERT INTO platform_settings (campaign_id, platform_id, budget, budget_percentage, ad_format, audience, bid_strategy, dayparting, dayparting_hours, tracking, created_at, updated_at) VALUES
(2, 1, 320.00, 40, 'single_image', 'food_enthusiasts', 'automatic', true, '[9,10,11,12,13,14,15,16,17,18]', true, '2025-03-01', '2025-03-01'),  -- Instagram
(2, 2, 240.00, 30, 'single_image', 'local_residents', 'automatic', true, '[9,10,11,12,13,14,15,16,17,18]', true, '2025-03-01', '2025-03-01'),  -- Facebook
(2, 3, 240.00, 30, 'text', 'food_enthusiasts', 'manual', false, NULL, true, '2025-03-01', '2025-03-01');  -- Google

-- Platform settings for other campaigns (similar pattern)
-- Date Night Special (Campaign ID: 4) for Pasta Paradise
INSERT INTO platform_settings (campaign_id, platform_id, budget, budget_percentage, ad_format, audience, bid_strategy, created_at, updated_at) VALUES
(4, 1, 350.00, 35, 'carousel', 'food_enthusiasts', 'automatic', '2025-02-25', '2025-02-25'),  -- Instagram
(4, 2, 300.00, 30, 'carousel', 'local_residents', 'automatic', '2025-02-25', '2025-02-25'),  -- Facebook
(4, 3, 250.00, 25, 'text', 'food_enthusiasts', 'manual', '2025-02-25', '2025-02-25'),  -- Google
(4, 4, 100.00, 10, 'newsletter', 'existing_customers', 'automatic', '2025-02-25', '2025-02-25');  -- Email

-- Breakfast Special (Campaign ID: 6) for Hometown Diner
INSERT INTO platform_settings (campaign_id, platform_id, budget, budget_percentage, ad_format, audience, bid_strategy, created_at, updated_at) VALUES
(6, 1, 270.00, 30, 'carousel', 'local_residents', 'automatic', '2025-02-20', '2025-02-20'),  -- Instagram
(6, 2, 270.00, 30, 'carousel', 'local_residents', 'automatic', '2025-02-20', '2025-02-20'),  -- Facebook
(6, 3, 360.00, 40, 'text', 'food_enthusiasts', 'manual', '2025-02-20', '2025-02-20');  -- Google

-- Campaign metrics for Weekend Special Promotion (daily data for March)
INSERT INTO campaign_metrics (campaign_id, date, impressions, clicks, spend, conversions, created_at) VALUES
(1, '2025-03-01', 1200, 78, 15.00, 6, '2025-03-02'),
(1, '2025-03-02', 1250, 82, 15.50, 7, '2025-03-03'),
(1, '2025-03-03', 1320, 85, 16.20, 6, '2025-03-04'),
(1, '2025-03-04', 1350, 87, 16.80, 7, '2025-03-05'),
(1, '2025-03-05', 1520, 98, 18.70, 8, '2025-03-06'),
(1, '2025-03-06', 1650, 107, 20.20, 9, '2025-03-07'),
(1, '2025-03-07', 1700, 110, 20.90, 9, '2025-03-08'),
(1, '2025-03-08', 1580, 102, 19.40, 8, '2025-03-09'),
(1, '2025-03-09', 1620, 105, 19.90, 8, '2025-03-10'),
(1, '2025-03-10', 1720, 111, 21.10, 9, '2025-03-11'),
(1, '2025-03-11', 1810, 117, 22.30, 10, '2025-03-12'),
(1, '2025-03-12', 1890, 122, 23.20, 10, '2025-03-13'),
(1, '2025-03-13', 1930, 125, 23.70, 10, '2025-03-14'),
(1, '2025-03-14', 1760, 114, 21.60, 9, '2025-03-15'),
(1, '2025-03-15', 1890, 122, 23.20, 10, '2025-03-16'),
(1, '2025-03-16', 1810, 117, 22.30, 9, '2025-03-17'),
(1, '2025-03-17', 1720, 111, 21.10, 9, '2025-03-18'),
(1, '2025-03-18', 1650, 107, 20.20, 8, '2025-03-19'),
(1, '2025-03-19', 1580, 102, 19.40, 8, '2025-03-20'),
(1, '2025-03-20', 1930, 125, 23.70, 10, '2025-03-21'),
(1, '2025-03-21', 2010, 130, 24.50, 11, '2025-03-22'),
(1, '2025-03-22', 1960, 127, 24.00, 10, '2025-03-23'),
(1, '2025-03-23', 1890, 122, 23.20, 10, '2025-03-24'),
(1, '2025-03-24', 1810, 117, 22.30, 9, '2025-03-25'),
(1, '2025-03-25', 1760, 114, 21.60, 9, '2025-03-26'),
(1, '2025-03-26', 1720, 111, 21.10, 9, '2025-03-27'),
(1, '2025-03-27', 1650, 107, 20.20, 8, '2025-03-28'),
(1, '2025-03-28', 1580, 102, 19.40, 8, '2025-03-29'),
(1, '2025-03-29', 1520, 98, 18.70, 8, '2025-03-30'),
(1, '2025-03-30', 1350, 87, 16.80, 7, '2025-03-31');

-- Campaign metrics for Taco Tuesday (starting from March 15th)
INSERT INTO campaign_metrics (campaign_id, date, impressions, clicks, spend, conversions, created_at) VALUES
(2, '2025-03-15', 980, 63, 12.60, 5, '2025-03-16'),
(2, '2025-03-16', 920, 59, 11.80, 5, '2025-03-17'),
(2, '2025-03-17', 1050, 68, 13.50, 6, '2025-03-18'),
(2, '2025-03-18', 1120, 72, 14.40, 6, '2025-03-19'),
(2, '2025-03-19', 1080, 70, 13.90, 6, '2025-03-20'),
(2, '2025-03-20', 1030, 67, 13.30, 5, '2025-03-21'),
(2, '2025-03-21', 1210, 78, 15.60, 7, '2025-03-22'),
(2, '2025-03-22', 1350, 87, 17.40, 7, '2025-03-23'),
(2, '2025-03-23', 1250, 81, 16.10, 7, '2025-03-24'),
(2, '2025-03-24', 1150, 74, 14.80, 6, '2025-03-25'),
(2, '2025-03-25', 1350, 87, 17.40, 7, '2025-03-26'),
(2, '2025-03-26', 1450, 94, 18.70, 8, '2025-03-27'),
(2, '2025-03-27', 1550, 100, 20.00, 9, '2025-03-28'),
(2, '2025-03-28', 1650, 107, 21.30, 9, '2025-03-29'),
(2, '2025-03-29', 1720, 111, 22.20, 10, '2025-03-30'),
(2, '2025-03-30', 1680, 109, 21.70, 9, '2025-03-31');

-- Platform metrics for Weekend Special Promotion - Instagram (Platform Settings ID: 1)
INSERT INTO platform_metrics (platform_settings_id, date, impressions, clicks, spend, conversions, created_at) VALUES
(1, '2025-03-01', 420, 27, 5.25, 2, '2025-03-02'),
(1, '2025-03-02', 438, 29, 5.43, 2, '2025-03-03'),
(1, '2025-03-03', 462, 30, 5.67, 2, '2025-03-04'),
(1, '2025-03-04', 473, 30, 5.88, 2, '2025-03-05'),
(1, '2025-03-05', 532, 34, 6.55, 3, '2025-03-06'),
(1, '2025-03-06', 578, 37, 7.07, 3, '2025-03-07'),
(1, '2025-03-07', 595, 39, 7.32, 3, '2025-03-08'),
(1, '2025-03-08', 553, 36, 6.79, 3, '2025-03-09'),
(1, '2025-03-09', 567, 37, 6.97, 3, '2025-03-10'),
(1, '2025-03-10', 602, 39, 7.39, 3, '2025-03-11'),
(1, '2025-03-11', 634, 41, 7.81, 3, '2025-03-12'),
(1, '2025-03-12', 662, 43, 8.12, 4, '2025-03-13'),
(1, '2025-03-13', 676, 44, 8.30, 4, '2025-03-14'),
(1, '2025-03-14', 616, 40, 7.56, 3, '2025-03-15'),
(1, '2025-03-15', 662, 43, 8.12, 4, '2025-03-16'),
(1, '2025-03-16', 634, 41, 7.81, 3, '2025-03-17'),
(1, '2025-03-17', 602, 39, 7.39, 3, '2025-03-18'),
(1, '2025-03-18', 578, 37, 7.07, 3, '2025-03-19'),
(1, '2025-03-19', 553, 36, 6.79, 3, '2025-03-20'),
(1, '2025-03-20', 676, 44, 8.30, 4, '2025-03-21'),
(1, '2025-03-21', 704, 46, 8.58, 4, '2025-03-22'),
(1, '2025-03-22', 686, 44, 8.40, 4, '2025-03-23'),
(1, '2025-03-23', 662, 43, 8.12, 4, '2025-03-24'),
(1, '2025-03-24', 634, 41, 7.81, 3, '2025-03-25'),
(1, '2025-03-25', 616, 40, 7.56, 3, '2025-03-26'),
(1, '2025-03-26', 602, 39, 7.39, 3, '2025-03-27'),
(1, '2025-03-27', 578, 37, 7.07, 3, '2025-03-28'),
(1, '2025-03-28', 553, 36, 6.79, 3, '2025-03-29'),
(1, '2025-03-29', 532, 34, 6.55, 3, '2025-03-30'),
(1, '2025-03-30', 473, 30, 5.88, 2, '2025-03-31');

-- Platform metrics for Weekend Special Promotion - Facebook (Platform Settings ID: 2)
INSERT INTO platform_metrics (platform_settings_id, date, impressions, clicks, spend, conversions, created_at) VALUES
(2, '2025-03-01', 300, 20, 3.75, 2, '2025-03-02'),
(2, '2025-03-02', 313, 21, 3.88, 2, '2025-03-03'),
(2, '2025-03-03', 330, 21, 4.05, 2, '2025-03-04'),
(2, '2025-03-04', 338, 22, 4.20, 2, '2025-03-05'),
(2, '2025-03-05', 380, 25, 4.68, 2, '2025-03-06'),
(2, '2025-03-06', 413, 27, 5.05, 2, '2025-03-07'),
(2, '2025-03-07', 425, 28, 5.23, 2, '2025-03-08'),
(2, '2025-03-08', 395, 26, 4.85, 2, '2025-03-09'),
(2, '2025-03-09', 405, 26, 4.98, 2, '2025-03-10'),
(2, '2025-03-10', 430, 28, 5.28, 2, '2025-03-11'),
(2, '2025-03-11', 453, 29, 5.58, 2, '2025-03-12'),
(2, '2025-03-12', 473, 31, 5.80, 3, '2025-03-13'),
(2, '2025-03-13', 483, 31, 5.93, 3, '2025-03-14'),
(2, '2025-03-14', 440, 29, 5.40, 2, '2025-03-15'),
(2, '2025-03-15', 473, 31, 5.80, 3, '2025-03-16'),
(2, '2025-03-16', 453, 29, 5.58, 2, '2025-03-17'),
(2, '2025-03-17', 430, 28, 5.28, 2, '2025-03-18'),
(2, '2025-03-18', 413, 27, 5.05, 2, '2025-03-19'),
(2, '2025-03-19', 395, 26, 4.85, 2, '2025-03-20'),
(2, '2025-03-20', 483, 31, 5.93, 3, '2025-03-21'),
(2, '2025-03-21', 503, 33, 6.13, 3, '2025-03-22'),
(2, '2025-03-22', 490, 32, 6.00, 3, '2025-03-23'),
(2, '2025-03-23', 473, 31, 5.80, 3, '2025-03-24'),
(2, '2025-03-24', 453, 29, 5.58, 2, '2025-03-25'),
(2, '2025-03-25', 440, 29, 5.40, 2, '2025-03-26'),
(2, '2025-03-26', 430, 28, 5.28, 2, '2025-03-27'),
(2, '2025-03-27', 413, 27, 5.05, 2, '2025-03-28'),
(2, '2025-03-28', 395, 26, 4.85, 2, '2025-03-29'),
(2, '2025-03-29', 380, 25, 4.68, 2, '2025-03-30'),
(2, '2025-03-30', 338, 22, 4.20, 2, '2025-03-31');

-- Platform metrics for Weekend Special Promotion - Google (Platform Settings ID: 3)
INSERT INTO platform_metrics (platform_settings_id, date, impressions, clicks, spend, conversions, created_at) VALUES
(3, '2025-03-01', 360, 23, 4.50, 2, '2025-03-02'),
(3, '2025-03-02', 375, 24, 4.65, 2, '2025-03-03'),
(3, '2025-03-03', 396, 26, 4.86, 2, '2025-03-04'),
(3, '2025-03-04', 405, 26, 5.04, 2, '2025-03-05'),
(3, '2025-03-05', 456, 29, 5.61, 2, '2025-03-06'),
(3, '2025-03-06', 495, 32, 6.06, 3, '2025-03-07'),
(3, '2025-03-07', 510, 33, 6.27, 3, '2025-03-08'),
(3, '2025-03-08', 474, 31, 5.82, 2, '2025-03-09'),
(3, '2025-03-09', 486, 31, 5.97, 2, '2025-03-10'),
(3, '2025-03-10', 516, 33, 6.33, 3, '2025-03-11'),
(3, '2025-03-11', 543, 35, 6.69, 3, '2025-03-12'),
(3, '2025-03-12', 567, 37, 6.96, 3, '2025-03-13'),
(3, '2025-03-13', 579, 37, 7.11, 3, '2025-03-14'),
(3, '2025-03-14', 528, 34, 6.48, 3, '2025-03-15'),
(3, '2025-03-15', 567, 37, 6.96, 3, '2025-03-16'),
(3, '2025-03-16', 543, 35, 6.69, 3, '2025-03-17'),
(3, '2025-03-17', 516, 33, 6.33, 3, '2025-03-18'),
(3, '2025-03-18', 495, 32, 6.06, 3, '2025-03-19'),
(3, '2025-03-19', 474, 31, 5.82, 2, '2025-03-20'),
(3, '2025-03-20', 579, 37, 7.11, 3, '2025-03-21'),
(3, '2025-03-21', 603, 39, 7.35, 3, '2025-03-22'),
(3, '2025-03-22', 588, 38, 7.20, 3, '2025-03-23'),
(3, '2025-03-23', 567, 37, 6.96, 3, '2025-03-24'),
(3, '2025-03-24', 543, 35, 6.69, 3, '2025-03-25'),
(3, '2025-03-25', 528, 34, 6.48, 3, '2025-03-26'),
(3, '2025-03-26', 516, 33, 6.33, 3, '2025-03-27'),
(3, '2025-03-27', 495, 32, 6.06, 3, '2025-03-28'),
(3, '2025-03-28', 474, 31, 5.82, 2, '2025-03-29'),
(3, '2025-03-29', 456, 29, 5.61, 2, '2025-03-30'),
(3, '2025-03-30', 405, 26, 5.04, 2, '2025-03-31');

-- Platform metrics for Weekend Special Promotion - Email (Platform Settings ID: 4)
INSERT INTO platform_metrics (platform_settings_id, date, impressions, clicks, spend, conversions, created_at) VALUES
(4, '2025-03-01', 120, 8, 1.50, 0, '2025-03-02'),
(4, '2025-03-02', 125, 8, 1.55, 1, '2025-03-03'),
(4, '2025-03-03', 132, 9, 1.62, 0, '2025-03-04'),
(4, '2025-03-04', 135, 9, 1.68, 1, '2025-03-05'),
(4, '2025-03-05', 152, 10, 1.87, 1, '2025-03-06'),
(4, '2025-03-06', 165, 11, 2.02, 1, '2025-03-07'),
(4, '2025-03-07', 170, 11, 2.09, 1, '2025-03-08'),
(4, '2025-03-08', 158, 10, 1.94, 1, '2025-03-09'),
(4, '2025-03-09', 162, 11, 1.99, 1, '2025-03-10'),
(4, '2025-03-10', 172, 11, 2.11, 1, '2025-03-11'),
(4, '2025-03-11', 181, 12, 2.23, 2, '2025-03-12'),
(4, '2025-03-12', 189, 12, 2.32, 0, '2025-03-13'),
(4, '2025-03-13', 193, 13, 2.37, 1, '2025-03-14'),
(4, '2025-03-14', 176, 11, 2.16, 1, '2025-03-15'),
(4, '2025-03-15', 189, 12, 2.32, 0, '2025-03-16'),
(4, '2025-03-16', 181, 12, 2.23, 1, '2025-03-17'),
(4, '2025-03-17', 172, 11, 2.11, 1, '2025-03-18'),
(4, '2025-03-18', 165, 11, 2.02, 0, '2025-03-19'),
(4, '2025-03-19', 158, 10, 1.94, 1, '2025-03-20'),
(4, '2025-03-20', 193, 13, 2.37, 0, '2025-03-21'),
(4, '2025-03-21', 201, 13, 2.45, 1, '2025-03-22'),
(4, '2025-03-22', 196, 13, 2.40, 0, '2025-03-23'),
(4, '2025-03-23', 189, 12, 2.32, 0, '2025-03-24'),
(4, '2025-03-24', 181, 12, 2.23, 1, '2025-03-25'),
(4, '2025-03-25', 176, 11, 2.16, 1, '2025-03-26'),
(4, '2025-03-26', 172, 11, 2.11, 1, '2025-03-27'),
(4, '2025-03-27', 165, 11, 2.02, 0, '2025-03-28'),
(4, '2025-03-28', 158, 10, 1.94, 1, '2025-03-29'),
(4, '2025-03-29', 152, 10, 1.87, 1, '2025-03-30'),
(4, '2025-03-30', 135, 9, 1.68, 1, '2025-03-31');

-- Platform metrics for Taco Tuesday - Instagram (Platform Settings ID: 5)
INSERT INTO platform_metrics (platform_settings_id, date, impressions, clicks, spend, conversions, created_at) VALUES
(5, '2025-03-15', 392, 25, 5.04, 2, '2025-03-16'),
(5, '2025-03-16', 368, 24, 4.72, 2, '2025-03-17'),
(5, '2025-03-17', 420, 27, 5.40, 2, '2025-03-18'),
(5, '2025-03-18', 448, 29, 5.76, 2, '2025-03-19'),
(5, '2025-03-19', 432, 28, 5.56, 2, '2025-03-20'),
(5, '2025-03-20', 412, 27, 5.32, 2, '2025-03-21'),
(5, '2025-03-21', 484, 31, 6.24, 3, '2025-03-22'),
(5, '2025-03-22', 540, 35, 6.96, 3, '2025-03-23'),
(5, '2025-03-23', 500, 32, 6.44, 3, '2025-03-24'),
(5, '2025-03-24', 460, 30, 5.92, 2, '2025-03-25'),
(5, '2025-03-25', 540, 35, 6.96, 3, '2025-03-26'),
(5, '2025-03-26', 580, 38, 7.48, 3, '2025-03-27'),
(5, '2025-03-27', 620, 40, 8.00, 4, '2025-03-28'),
(5, '2025-03-28', 660, 43, 8.52, 4, '2025-03-29'),
(5, '2025-03-29', 688, 44, 8.88, 4, '2025-03-30'),
(5, '2025-03-30', 672, 44, 8.68, 4, '2025-03-31');

-- Platform metrics for Taco Tuesday - Facebook (Platform Settings ID: 6)
INSERT INTO platform_metrics (platform_settings_id, date, impressions, clicks, spend, conversions, created_at) VALUES
(6, '2025-03-15', 294, 19, 3.78, 2, '2025-03-16'),
(6, '2025-03-16', 276, 18, 3.54, 2, '2025-03-17'),
(6, '2025-03-17', 315, 20, 4.05, 2, '2025-03-18'),
(6, '2025-03-18', 336, 22, 4.32, 2, '2025-03-19'),
(6, '2025-03-19', 324, 21, 4.17, 2, '2025-03-20'),
(6, '2025-03-20', 309, 20, 3.99, 1, '2025-03-21'),
(6, '2025-03-21', 363, 23, 4.68, 2, '2025-03-22'),
(6, '2025-03-22', 405, 26, 5.22, 2, '2025-03-23'),
(6, '2025-03-23', 375, 24, 4.83, 2, '2025-03-24'),
(6, '2025-03-24', 345, 22, 4.44, 2, '2025-03-25'),
(6, '2025-03-25', 405, 26, 5.22, 2, '2025-03-26'),
(6, '2025-03-26', 435, 28, 5.61, 2, '2025-03-27'),
(6, '2025-03-27', 465, 30, 6.00, 3, '2025-03-28'),
(6, '2025-03-28', 495, 32, 6.39, 3, '2025-03-29'),
(6, '2025-03-29', 516, 33, 6.66, 3, '2025-03-30'),
(6, '2025-03-30', 504, 33, 6.51, 3, '2025-03-31');

-- Platform metrics for Taco Tuesday - Google (Platform Settings ID: 7)
INSERT INTO platform_metrics (platform_settings_id, date, impressions, clicks, spend, conversions, created_at) VALUES
(7, '2025-03-15', 294, 19, 3.78, 1, '2025-03-16'),
(7, '2025-03-16', 276, 18, 3.54, 1, '2025-03-17'),
(7, '2025-03-17', 315, 20, 4.05, 2, '2025-03-18'),
(7, '2025-03-18', 336, 22, 4.32, 2, '2025-03-19'),
(7, '2025-03-19', 324, 21, 4.17, 2, '2025-03-20'),
(7, '2025-03-20', 309, 20, 3.99, 2, '2025-03-21'),
(7, '2025-03-21', 363, 23, 4.68, 2, '2025-03-22'),
(7, '2025-03-22', 405, 26, 5.22, 2, '2025-03-23'),
(7, '2025-03-23', 375, 24, 4.83, 2, '2025-03-24'),
(7, '2025-03-24', 345, 22, 4.44, 2, '2025-03-25'),
(7, '2025-03-25', 405, 26, 5.22, 2, '2025-03-26'),
(7, '2025-03-26', 435, 28, 5.61, 3, '2025-03-27'),
(7, '2025-03-27', 465, 30, 6.00, 2, '2025-03-28'),
(7, '2025-03-28', 495, 32, 6.39, 2, '2025-03-29'),
(7, '2025-03-29', 516, 33, 6.66, 3, '2025-03-30'),
(7, '2025-03-30', 504, 33, 6.51, 2, '2025-03-31');

-- Campaign conversions for Weekend Special Promotion (Campaign ID: 1)
INSERT INTO campaign_conversions (campaign_id, date, type, count, created_at) VALUES
-- Phone calls
(1, '2025-03-01', 'call', 2, '2025-03-02'),
(1, '2025-03-02', 'call', 3, '2025-03-03'),
(1, '2025-03-03', 'call', 2, '2025-03-04'),
(1, '2025-03-04', 'call', 3, '2025-03-05'),
(1, '2025-03-05', 'call', 3, '2025-03-06'),
(1, '2025-03-06', 'call', 4, '2025-03-07'),
(1, '2025-03-07', 'call', 4, '2025-03-08'),
(1, '2025-03-08', 'call', 3, '2025-03-09'),
(1, '2025-03-09', 'call', 3, '2025-03-10'),
(1, '2025-03-10', 'call', 4, '2025-03-11'),
(1, '2025-03-11', 'call', 4, '2025-03-12'),
(1, '2025-03-12', 'call', 4, '2025-03-13'),
(1, '2025-03-13', 'call', 4, '2025-03-14'),
(1, '2025-03-14', 'call', 3, '2025-03-15'),
(1, '2025-03-15', 'call', 4, '2025-03-16'),
-- Directions
(1, '2025-03-01', 'direction', 1, '2025-03-02'),
(1, '2025-03-02', 'direction', 1, '2025-03-03'),
(1, '2025-03-03', 'direction', 1, '2025-03-04'),
(1, '2025-03-04', 'direction', 1, '2025-03-05'),
(1, '2025-03-05', 'direction', 2, '2025-03-06'),
(1, '2025-03-06', 'direction', 2, '2025-03-07'),
(1, '2025-03-07', 'direction', 2, '2025-03-08'),
(1, '2025-03-08', 'direction', 2, '2025-03-09'),
(1, '2025-03-09', 'direction', 2, '2025-03-10'),
(1, '2025-03-10', 'direction', 2, '2025-03-11'),
(1, '2025-03-11', 'direction', 2, '2025-03-12'),
(1, '2025-03-12', 'direction', 2, '2025-03-13'),
(1, '2025-03-13', 'direction', 2, '2025-03-14'),
(1, '2025-03-14', 'direction', 2, '2025-03-15'),
(1, '2025-03-15', 'direction', 2, '2025-03-16'),
-- Online orders
(1, '2025-03-01', 'order', 2, '2025-03-02'),
(1, '2025-03-02', 'order', 2, '2025-03-03'),
(1, '2025-03-03', 'order', 2, '2025-03-04'),
(1, '2025-03-04', 'order', 2, '2025-03-05'),
(1, '2025-03-05', 'order', 2, '2025-03-06'),
(1, '2025-03-06', 'order', 2, '2025-03-07'),
(1, '2025-03-07', 'order', 2, '2025-03-08'),
(1, '2025-03-08', 'order', 2, '2025-03-09'),
(1, '2025-03-09', 'order', 2, '2025-03-10'),
(1, '2025-03-10', 'order', 2, '2025-03-11'),
(1, '2025-03-11', 'order', 3, '2025-03-12'),
(1, '2025-03-12', 'order', 3, '2025-03-13'),
(1, '2025-03-13', 'order', 3, '2025-03-14'),
(1, '2025-03-14', 'order', 3, '2025-03-15'),
(1, '2025-03-15', 'order', 3, '2025-03-16'),
-- Reservations
(1, '2025-03-01', 'reservation', 1, '2025-03-02'),
(1, '2025-03-02', 'reservation', 1, '2025-03-03'),
(1, '2025-03-03', 'reservation', 1, '2025-03-04'),
(1, '2025-03-04', 'reservation', 1, '2025-03-05'),
(1, '2025-03-05', 'reservation', 1, '2025-03-06'),
(1, '2025-03-06', 'reservation', 1, '2025-03-07'),
(1, '2025-03-07', 'reservation', 1, '2025-03-08'),
(1, '2025-03-08', 'reservation', 1, '2025-03-09'),
(1, '2025-03-09', 'reservation', 1, '2025-03-10'),
(1, '2025-03-10', 'reservation', 1, '2025-03-11'),
(1, '2025-03-11', 'reservation', 1, '2025-03-12'),
(1, '2025-03-12', 'reservation', 1, '2025-03-13'),
(1, '2025-03-13', 'reservation', 1, '2025-03-14'),
(1, '2025-03-14', 'reservation', 1, '2025-03-15'),
(1, '2025-03-15', 'reservation', 1, '2025-03-16');

-- Create useful views for reporting

-- View: campaign_overview
CREATE OR REPLACE VIEW campaign_overview AS
SELECT 
    c.id, 
    c.name,
    c.status,
    c.budget,
    c.spent,
    r.name AS restaurant_name,
    c.start_date,
    c.end_date,
    COALESCE(SUM(cm.impressions), 0) AS total_impressions,
    COALESCE(SUM(cm.clicks), 0) AS total_clicks,
    COALESCE(SUM(cm.conversions), 0) AS total_conversions,
    CASE 
        WHEN COALESCE(SUM(cm.impressions), 0) > 0 
        THEN ROUND((COALESCE(SUM(cm.clicks), 0)::NUMERIC / COALESCE(SUM(cm.impressions), 0)) * 100, 2)
        ELSE 0
    END AS ctr,
    CASE 
        WHEN COALESCE(SUM(cm.clicks), 0) > 0 
        THEN ROUND((COALESCE(SUM(cm.conversions), 0)::NUMERIC / COALESCE(SUM(cm.clicks), 0)) * 100, 2)
        ELSE 0
    END AS conversion_rate,
    CASE 
        WHEN COALESCE(SUM(cm.conversions), 0) > 0 
        THEN ROUND(COALESCE(SUM(cm.spend), 0) / COALESCE(SUM(cm.conversions), 0), 2)
        ELSE 0
    END AS cost_per_conversion
FROM 
    campaigns c
JOIN 
    restaurants r ON c.restaurant_id = r.id
LEFT JOIN 
    campaign_metrics cm ON c.id = cm.campaign_id
GROUP BY 
    c.id, c.name, c.status, c.budget, c.spent, r.name, c.start_date, c.end_date;

-- View: platform_overview
CREATE OR REPLACE VIEW platform_overview AS
SELECT 
    ps.id AS platform_setting_id,
    c.id AS campaign_id,
    c.name AS campaign_name,
    p.id AS platform_id,
    p.name AS platform_name,
    p.type AS platform_type,
    ps.budget,
    ps.budget_percentage,
    ps.ad_format,
    COALESCE(SUM(pm.impressions), 0) AS total_impressions,
    COALESCE(SUM(pm.clicks), 0) AS total_clicks,
    COALESCE(SUM(pm.spend), 0) AS total_spend,
    COALESCE(SUM(pm.conversions), 0) AS total_conversions,
    CASE 
        WHEN COALESCE(SUM(pm.impressions), 0) > 0 
        THEN ROUND((COALESCE(SUM(pm.clicks), 0)::NUMERIC / COALESCE(SUM(pm.impressions), 0)) * 100, 2)
        ELSE 0
    END AS ctr,
    CASE 
        WHEN COALESCE(SUM(pm.clicks), 0) > 0 
        THEN ROUND((COALESCE(SUM(pm.conversions), 0)::NUMERIC / COALESCE(SUM(pm.clicks), 0)) * 100, 2)
        ELSE 0
    END AS conversion_rate,
    CASE 
        WHEN COALESCE(SUM(pm.clicks), 0) > 0 
        THEN ROUND(COALESCE(SUM(pm.spend), 0) / COALESCE(SUM(pm.clicks), 0), 2)
        ELSE 0
    END AS cpc,
    CASE 
        WHEN COALESCE(SUM(pm.conversions), 0) > 0 
        THEN ROUND(COALESCE(SUM(pm.spend), 0) / COALESCE(SUM(pm.conversions), 0), 2)
        ELSE 0
    END AS cost_per_conversion
FROM 
    platform_settings ps
JOIN 
    campaigns c ON ps.campaign_id = c.id
JOIN 
    platforms p ON ps.platform_id = p.id
LEFT JOIN 
    platform_metrics pm ON ps.id = pm.platform_settings_id
GROUP BY 
    ps.id, c.id, c.name, p.id, p.name, p.type, ps.budget, ps.budget_percentage, ps.ad_format;

-- View: conversion_breakdown
CREATE OR REPLACE VIEW conversion_breakdown AS
SELECT 
    c.id AS campaign_id,
    c.name AS campaign_name,
    r.name AS restaurant_name,
    cc.type AS conversion_type,
    SUM(cc.count) AS total_count
FROM 
    campaigns c
JOIN 
    restaurants r ON c.restaurant_id = r.id
JOIN 
    campaign_conversions cc ON c.id = cc.campaign_id
GROUP BY 
    c.id, c.name, r.name, cc.type;

-- View: customer_metrics
CREATE OR REPLACE VIEW customer_metrics AS
SELECT
    r.id AS restaurant_id,
    r.name AS restaurant_name,
    COUNT(c.id) AS total_customers,
    COUNT(CASE WHEN c.order_count > 0 THEN 1 END) AS customers_with_orders,
    ROUND(AVG(c.order_count), 2) AS avg_orders_per_customer,
    ROUND(AVG(c.total_spent), 2) AS avg_spend_per_customer,
    SUM(c.total_spent) AS total_revenue,
    COUNT(CASE WHEN c.created_at > (CURRENT_DATE - INTERVAL '30 days') THEN 1 END) AS new_customers_last_30_days,
    COUNT(CASE WHEN c.last_order_date > (CURRENT_DATE - INTERVAL '30 days') THEN 1 END) AS active_customers_last_30_days
FROM
    restaurants r
LEFT JOIN
    customers c ON r.id = c.restaurant_id
GROUP BY
    r.id, r.name;

-- Sample queries for common reports

-- 1. Campaign performance overview
-- SELECT * FROM campaign_overview ORDER BY id;

-- 2. Platform performance for a specific campaign
-- SELECT * FROM platform_overview WHERE campaign_id = 1 ORDER BY total_clicks DESC;

-- 3. Conversion types breakdown by campaign
-- SELECT * FROM conversion_breakdown ORDER BY campaign_id, conversion_type;

-- 4. Customer metrics by restaurant
-- SELECT * FROM customer_metrics ORDER BY restaurant_id;

-- 5. Daily metrics for a campaign over time
-- SELECT 
--     date, 
--     impressions, 
--     clicks, 
--     spend, 
--     conversions,
--     CASE WHEN impressions > 0 THEN ROUND((clicks::NUMERIC / impressions) * 100, 2) ELSE 0 END AS ctr
-- FROM 
--     campaign_metrics 
-- WHERE 
--     campaign_id = 1 
-- ORDER BY 
--     date;

-- 6. Platform comparison across all campaigns
-- SELECT 
--     p.name AS platform_name,
--     p.type AS platform_type,
--     COUNT(DISTINCT ps.campaign_id) AS campaigns_count,
--     SUM(ps.budget) AS total_budget,
--     SUM(pm.impressions) AS total_impressions,
--     SUM(pm.clicks) AS total_clicks,
--     SUM(pm.conversions) AS total_conversions,
--     CASE WHEN SUM(pm.impressions) > 0 THEN ROUND((SUM(pm.clicks)::NUMERIC / SUM(pm.impressions)) * 100, 2) ELSE 0 END AS avg_ctr,
--     CASE WHEN SUM(pm.clicks) > 0 THEN ROUND((SUM(pm.conversions)::NUMERIC / SUM(pm.clicks)) * 100, 2) ELSE 0 END AS avg_conversion_rate,
--     CASE WHEN SUM(pm.clicks) > 0 THEN ROUND(SUM(pm.spend) / SUM(pm.clicks), 2) ELSE 0 END AS avg_cpc,
--     CASE WHEN SUM(pm.conversions) > 0 THEN ROUND(SUM(pm.spend) / SUM(pm.conversions), 2) ELSE 0 END AS avg_cpa
-- FROM 
--     platforms p
-- LEFT JOIN 
--     platform_settings ps ON p.id = ps.platform_id
-- LEFT JOIN 
--     platform_metrics pm ON ps.id = pm.platform_settings_id
-- GROUP BY 
--     p.id, p.name, p.type
-- ORDER BY 
--     total_conversions DESC;

-- 7. Customer acquisition cost analysis
-- SELECT 
--     c.id AS campaign_id,
--     c.name AS campaign_name,
--     c.spent,
--     COUNT(DISTINCT cu.id) AS new_customers,
--     CASE 
--         WHEN COUNT(DISTINCT cu.id) > 0 
--         THEN ROUND(c.spent / COUNT(DISTINCT cu.id), 2)
--         ELSE c.spent
--     END AS acquisition_cost
-- FROM 
--     campaigns c
-- JOIN 
--     restaurants r ON c.restaurant_id = r.id
-- JOIN 
--     customers cu ON r.id = cu.restaurant_id AND cu.created_at BETWEEN c.start_date AND c.end_date
-- GROUP BY 
--     c.id, c.name, c.spent
-- ORDER BY 
--     acquisition_cost;

-- 8. Create functions for commonly used analytics

-- Function to get campaign performance for a date range
CREATE OR REPLACE FUNCTION get_campaign_performance(
    campaign_id_param INTEGER,
    start_date_param DATE,
    end_date_param DATE
) RETURNS TABLE (
    date DATE,
    impressions BIGINT,
    clicks BIGINT,
    spend NUMERIC,
    conversions BIGINT,
    ctr NUMERIC,
    cost_per_click NUMERIC,
    conversion_rate NUMERIC,
    cost_per_conversion NUMERIC
) AS $
BEGIN
    RETURN QUERY
    SELECT 
        cm.date,
        SUM(cm.impressions) AS impressions,
        SUM(cm.clicks) AS clicks,
        SUM(cm.spend) AS spend,
        SUM(cm.conversions) AS conversions,
        CASE 
            WHEN SUM(cm.impressions) > 0 
            THEN ROUND((SUM(cm.clicks)::NUMERIC / SUM(cm.impressions)) * 100, 2)
            ELSE 0
        END AS ctr,
        CASE 
            WHEN SUM(cm.clicks) > 0 
            THEN ROUND(SUM(cm.spend) / SUM(cm.clicks), 2)
            ELSE 0
        END AS cost_per_click,
        CASE 
            WHEN SUM(cm.clicks) > 0 
            THEN ROUND((SUM(cm.conversions)::NUMERIC / SUM(cm.clicks)) * 100, 2)
            ELSE 0
        END AS conversion_rate,
        CASE 
            WHEN SUM(cm.conversions) > 0 
            THEN ROUND(SUM(cm.spend) / SUM(cm.conversions), 2)
            ELSE 0
        END AS cost_per_conversion
    FROM 
        campaign_metrics cm
    WHERE 
        cm.campaign_id = campaign_id_param
        AND cm.date BETWEEN start_date_param AND end_date_param
    GROUP BY 
        cm.date
    ORDER BY 
        cm.date;
END;
$ LANGUAGE plpgsql;

-- Function to get platform performance comparison
CREATE OR REPLACE FUNCTION get_platform_comparison(
    campaign_id_param INTEGER
) RETURNS TABLE (
    platform_id INTEGER,
    platform_name VARCHAR,
    platform_type VARCHAR,
    impressions BIGINT,
    clicks BIGINT,
    spend NUMERIC,
    conversions BIGINT,
    ctr NUMERIC,
    conversion_rate NUMERIC,
    cpc NUMERIC,
    cost_per_conversion NUMERIC,
    budget_percentage INTEGER
) AS $
BEGIN
    RETURN QUERY
    SELECT 
        p.id AS platform_id,
        p.name AS platform_name,
        p.type AS platform_type,
        COALESCE(SUM(pm.impressions), 0) AS impressions,
        COALESCE(SUM(pm.clicks), 0) AS clicks,
        COALESCE(SUM(pm.spend), 0) AS spend,
        COALESCE(SUM(pm.conversions), 0) AS conversions,
        CASE 
            WHEN COALESCE(SUM(pm.impressions), 0) > 0 
            THEN ROUND((COALESCE(SUM(pm.clicks), 0)::NUMERIC / COALESCE(SUM(pm.impressions), 0)) * 100, 2)
            ELSE 0
        END AS ctr,
        CASE 
            WHEN COALESCE(SUM(pm.clicks), 0) > 0 
            THEN ROUND((COALESCE(SUM(pm.conversions), 0)::NUMERIC / COALESCE(SUM(pm.clicks), 0)) * 100, 2)
            ELSE 0
        END AS conversion_rate,
        CASE 
            WHEN COALESCE(SUM(pm.clicks), 0) > 0 
            THEN ROUND(COALESCE(SUM(pm.spend), 0) / COALESCE(SUM(pm.clicks), 0), 2)
            ELSE 0
        END AS cpc,
        CASE 
            WHEN COALESCE(SUM(pm.conversions), 0) > 0 
            THEN ROUND(COALESCE(SUM(pm.spend), 0) / COALESCE(SUM(pm.conversions), 0), 2)
            ELSE 0
        END AS cost_per_conversion,
        ps.budget_percentage
    FROM 
        platform_settings ps
    JOIN 
        platforms p ON ps.platform_id = p.id
    LEFT JOIN 
        platform_metrics pm ON ps.id = pm.platform_settings_id
    WHERE 
        ps.campaign_id = campaign_id_param
    GROUP BY 
        p.id, p.name, p.type, ps.budget_percentage
    ORDER BY 
        conversions DESC;
END;
$ LANGUAGE plpgsql;

-- Function to get conversion breakdown by type
CREATE OR REPLACE FUNCTION get_conversion_breakdown(
    campaign_id_param INTEGER,
    start_date_param DATE DEFAULT NULL,
    end_date_param DATE DEFAULT NULL
) RETURNS TABLE (
    conversion_type VARCHAR,
    total_count BIGINT,
    percentage NUMERIC
) AS $
DECLARE
    total_conversions BIGINT;
BEGIN
    -- Set default dates if not provided
    IF start_date_param IS NULL THEN
        SELECT start_date INTO start_date_param FROM campaigns WHERE id = campaign_id_param;
    END IF;
    
    IF end_date_param IS NULL THEN
        SELECT LEAST(end_date, CURRENT_DATE) INTO end_date_param FROM campaigns WHERE id = campaign_id_param;
    END IF;

    -- Get total conversions for percentage calculation
    SELECT SUM(count) INTO total_conversions
    FROM campaign_conversions
    WHERE campaign_id = campaign_id_param
    AND date BETWEEN start_date_param AND end_date_param;

    -- Return the breakdown
    RETURN QUERY
    SELECT 
        cc.type AS conversion_type,
        SUM(cc.count) AS total_count,
        CASE 
            WHEN total_conversions > 0 
            THEN ROUND((SUM(cc.count)::NUMERIC / total_conversions) * 100, 2)
            ELSE 0
        END AS percentage
    FROM 
        campaign_conversions cc
    WHERE 
        cc.campaign_id = campaign_id_param
        AND cc.date BETWEEN start_date_param AND end_date_param
    GROUP BY 
        cc.type
    ORDER BY 
        total_count DESC;
END;
$ LANGUAGE plpgsql;

-- Function to calculate ROI
CREATE OR REPLACE FUNCTION calculate_campaign_roi(
    campaign_id_param INTEGER,
    revenue_per_conversion NUMERIC DEFAULT 25.00  -- Default average value per conversion
) RETURNS TABLE (
    campaign_name VARCHAR,
    total_spend NUMERIC,
    estimated_revenue NUMERIC,
    roi NUMERIC,
    roi_percentage NUMERIC
) AS $
BEGIN
    RETURN QUERY
    SELECT 
        c.name AS campaign_name,
        c.spent AS total_spend,
        (SELECT COALESCE(SUM(conversions), 0) * revenue_per_conversion FROM campaign_metrics WHERE campaign_id = c.id) AS estimated_revenue,
        (SELECT COALESCE(SUM(conversions), 0) * revenue_per_conversion FROM campaign_metrics WHERE campaign_id = c.id) - c.spent AS roi,
        CASE 
            WHEN c.spent > 0 
            THEN ROUND((((SELECT COALESCE(SUM(conversions), 0) * revenue_per_conversion FROM campaign_metrics WHERE campaign_id = c.id) - c.spent) / c.spent) * 100, 2)
            ELSE 0
        END AS roi_percentage
    FROM 
        campaigns c
    WHERE 
        c.id = campaign_id_param;
END;
$ LANGUAGE plpgsql;

-- Add indexes for better performance
CREATE INDEX idx_campaign_metrics_campaign_id_date ON campaign_metrics(campaign_id, date);
CREATE INDEX idx_platform_metrics_platform_settings_id_date ON platform_metrics(platform_settings_id, date);
CREATE INDEX idx_platform_settings_campaign_id ON platform_settings(campaign_id);
CREATE INDEX idx_campaign_conversions_campaign_id_date ON campaign_conversions(campaign_id, date);
CREATE INDEX idx_customers_restaurant_id ON customers(restaurant_id);
CREATE INDEX idx_customers_created_at ON customers(created_at);
CREATE INDEX idx_customers_last_order_date ON customers(last_order_date);

-- Add triggers to update campaign spent amount automatically
CREATE OR REPLACE FUNCTION update_campaign_spent() RETURNS TRIGGER AS $
BEGIN
    UPDATE campaigns 
    SET spent = (SELECT COALESCE(SUM(spend), 0) FROM campaign_metrics WHERE campaign_id = NEW.campaign_id)
    WHERE id = NEW.campaign_id;
    RETURN NEW;
END;
$ LANGUAGE plpgsql;

CREATE TRIGGER campaign_metrics_update_spent
AFTER INSERT OR UPDATE ON campaign_metrics
FOR EACH ROW
EXECUTE FUNCTION update_campaign_spent();

-- Sample API endpoints (represented as functions)

-- 1. Get campaign overview
CREATE OR REPLACE FUNCTION api_get_campaign(campaign_id_param INTEGER)
RETURNS json AS $
DECLARE
    result json;
BEGIN
    SELECT row_to_json(co)
    INTO result
    FROM campaign_overview co
    WHERE co.id = campaign_id_param;
    
    RETURN result;
END;
$ LANGUAGE plpgsql;

-- 2. Get campaign list for a restaurant
CREATE OR REPLACE FUNCTION api_get_restaurant_campaigns(restaurant_id_param INTEGER)
RETURNS json AS $
DECLARE
    result json;
BEGIN
    SELECT json_agg(row_to_json(co))
    INTO result
    FROM campaign_overview co
    JOIN campaigns c ON co.id = c.id
    WHERE c.restaurant_id = restaurant_id_param
    ORDER BY c.created_at DESC;
    
    RETURN result;
END;
$ LANGUAGE plpgsql;

-- 3. Get platform performance for a campaign
CREATE OR REPLACE FUNCTION api_get_campaign_platforms(campaign_id_param INTEGER)
RETURNS json AS $
DECLARE
    result json;
BEGIN
    SELECT json_agg(platform)
    INTO result
    FROM get_platform_comparison(campaign_id_param) AS platform;
    
    RETURN result;
END;
$ LANGUAGE plpgsql;

-- 4. Get customer metrics for a restaurant
CREATE OR REPLACE FUNCTION api_get_customer_metrics(restaurant_id_param INTEGER)
RETURNS json AS $
DECLARE
    result json;
BEGIN
    SELECT row_to_json(cm)
    INTO result
    FROM customer_metrics cm
    WHERE cm.restaurant_id = restaurant_id_param;
    
    RETURN result;
END;
$ LANGUAGE plpgsql;

-- 5. Get conversion breakdown for a campaign
CREATE OR REPLACE FUNCTION api_get_conversion_breakdown(campaign_id_param INTEGER)
RETURNS json AS $
DECLARE
    result json;
BEGIN
    SELECT json_agg(breakdown)
    INTO result
    FROM get_conversion_breakdown(campaign_id_param) AS breakdown;
    
    RETURN result;
END;
$ LANGUAGE plpgsql;

-- Add database documentation

COMMENT ON TABLE users IS 'Store user accounts and authentication information';
COMMENT ON TABLE restaurants IS 'Restaurant information linked to user accounts';
COMMENT ON TABLE customers IS 'Customer data collected for each restaurant';
COMMENT ON TABLE campaigns IS 'Marketing campaigns created for restaurants';
COMMENT ON TABLE platforms IS 'Available advertising platforms';
COMMENT ON TABLE platform_settings IS 'Platform-specific settings for each campaign';
COMMENT ON TABLE campaign_metrics IS 'Daily performance metrics for each campaign';
COMMENT ON TABLE platform_metrics IS 'Daily platform-specific metrics for campaigns';
COMMENT ON TABLE campaign_conversions IS 'Conversion data by type for campaigns';

COMMENT ON VIEW campaign_overview IS 'Aggregated campaign performance metrics';
COMMENT ON VIEW platform_overview IS 'Platform performance metrics by campaign';
COMMENT ON VIEW conversion_breakdown IS 'Conversion type analysis by campaign';
COMMENT ON VIEW customer_metrics IS 'Customer analytics by restaurant';
COMMENT ON VIEW campaign_platform_metrics IS 'Combined campaign and platform metrics for reporting';

COMMENT ON FUNCTION get_campaign_performance IS 'Get detailed campaign performance metrics for a date range';
COMMENT ON FUNCTION get_platform_comparison IS 'Compare platform performance within a campaign';
COMMENT ON FUNCTION get_conversion_breakdown IS 'Analyze conversion types and their distribution';
COMMENT ON FUNCTION calculate_campaign_roi IS 'Calculate ROI based on conversions and average value';
COMMENT ON FUNCTION update_campaign_spent IS 'Trigger function to update campaign spent amount';
