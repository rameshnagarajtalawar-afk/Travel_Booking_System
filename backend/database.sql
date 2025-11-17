-- ==========================================
-- DATABASE: Travel Booking System (Minimal + Clean)
-- ==========================================

DROP DATABASE IF EXISTS travel_booking;
CREATE DATABASE travel_booking;
USE travel_booking;

-- =======================
-- 1. TABLES
-- =======================

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email_id VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    home_city VARCHAR(100),
    budget DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cities (
    city_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    best_season VARCHAR(50),
    description TEXT
);

CREATE TABLE transport (
    transport_id INT PRIMARY KEY AUTO_INCREMENT,
    mode ENUM('Flight', 'Train', 'Bus', 'Car', 'Ferry') NOT NULL,
    from_city_id INT,
    destination_city_id INT,
    cost DECIMAL(10, 2) NOT NULL,
    duration VARCHAR(50),
    seats_available INT,
    departure_time VARCHAR(50),
    FOREIGN KEY (from_city_id) REFERENCES cities(city_id),
    FOREIGN KEY (destination_city_id) REFERENCES cities(city_id)
);

CREATE TABLE establishments (
    establishment_id INT PRIMARY KEY AUTO_INCREMENT,
    city_id INT,
    name VARCHAR(200) NOT NULL,
    type ENUM('Hotel', 'Restaurant', 'Cafe', 'Bar') NOT NULL,
    rating DECIMAL(2, 1),
    address VARCHAR(300),
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

CREATE TABLE rooms (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    establishment_id INT,
    room_type ENUM('Single', 'Double', 'Suite', 'Deluxe'),
    price_per_night DECIMAL(10, 2),
    availability BOOLEAN DEFAULT TRUE,
    amenities TEXT,
    FOREIGN KEY (establishment_id) REFERENCES establishments(establishment_id)
);

CREATE TABLE food_menu (
    food_id INT PRIMARY KEY AUTO_INCREMENT,
    establishment_id INT,
    name VARCHAR(200),
    cuisine VARCHAR(100),
    rating DECIMAL(2, 1),
    price DECIMAL(10, 2),
    description TEXT,
    FOREIGN KEY (establishment_id) REFERENCES establishments(establishment_id)
);

CREATE TABLE attractions (
    attraction_id INT PRIMARY KEY AUTO_INCREMENT,
    city_id INT,
    name VARCHAR(200),
    category VARCHAR(100),
    entry_fee DECIMAL(10, 2),
    ratings DECIMAL(2, 1),
    about_attraction TEXT,
    opening_hours VARCHAR(100),
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_cost DECIMAL(10,2),
    service_type ENUM('Transport','Room','Attraction','Food'),
    service_id INT,
    booking_details TEXT,
    status ENUM('Confirmed','Pending','Cancelled') DEFAULT 'Confirmed',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    category ENUM('Attraction','Food','Room','Transport'),
    ratings DECIMAL(2,1),
    comments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    place_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- =======================
-- 2. SAMPLE DATA
-- =======================

INSERT INTO cities (name, country, best_season, description) VALUES
('Paris', 'France', 'Spring', 'The City of Light, famous for the Eiffel Tower and romantic atmosphere'),
('Tokyo', 'Japan', 'Spring', 'Modern metropolis blending rich traditions with cutting-edge technology'),
('New York', 'USA', 'Fall', 'The Big Apple - bustling city that never sleeps with iconic landmarks'),
('Bali', 'Indonesia', 'Summer', 'Tropical paradise with beautiful beaches and ancient temples'),
('London', 'UK', 'Summer', 'Historic city with iconic landmarks and royal heritage'),
('Dubai', 'UAE', 'Winter', 'Luxury destination with modern architecture and desert adventures');

INSERT INTO establishments (city_id, name, type, rating, address) VALUES
(1, 'Hotel Le Royal', 'Hotel', 4.5, '123 Champs-Élysées, Paris'),
(1, 'Cafe de Flore', 'Cafe', 4.8, '172 Boulevard Saint-Germain, Paris'),
(1, 'Le Gourmet', 'Restaurant', 4.7, '45 Rue de la Paix, Paris'),
(2, 'Tokyo Grand Hotel', 'Hotel', 4.7, '1-1-1 Shibuya, Tokyo'),
(2, 'Sushi Master', 'Restaurant', 4.9, '3-5-7 Ginza, Tokyo'),
(3, 'Manhattan Plaza Hotel', 'Hotel', 4.3, '123 5th Avenue, New York'),
(3, 'Brooklyn Diner', 'Restaurant', 4.6, '567 Broadway, New York'),
(4, 'Bali Beach Resort', 'Hotel', 4.8, 'Seminyak Beach, Bali'),
(4, 'Warung Bali', 'Restaurant', 4.5, 'Ubud Center, Bali'),
(5, 'Thames Hotel', 'Hotel', 4.4, '789 Westminster, London'),
(6, 'Al Fahidi Heritage Hotel', 'Hotel', 4.6, 'Al Fahidi Street, Bur Dubai, Dubai'),
(6, 'The Palm Grand Resort', 'Hotel', 4.7, 'Palm Jumeirah, Crescent Road, Dubai'),
(6, 'Arabian Nights Café', 'Cafe', 4.5, 'Jumeirah Beach Road, Dubai');

INSERT INTO rooms (establishment_id, room_type, price_per_night, availability, amenities) VALUES
(1, 'Single', 120.00, TRUE, 'WiFi, TV, AC, Mini Bar'),
(1, 'Double', 180.00, TRUE, 'WiFi, TV, AC, Mini Bar, City View'),
(1, 'Suite', 350.00, TRUE, 'WiFi, TV, AC, Mini Bar, City View, Jacuzzi'),
(4, 'Double', 200.00, TRUE, 'WiFi, TV, AC, Ocean View'),
(4, 'Deluxe', 280.00, TRUE, 'WiFi, TV, AC, Ocean View, Balcony'),
(6, 'Single', 150.00, TRUE, 'WiFi, TV, AC'),
(6, 'Suite', 300.00, TRUE, 'WiFi, TV, AC, Central Park View'),
(8, 'Double', 220.00, TRUE, 'WiFi, TV, AC, Beach View, Pool Access'),
(8, 'Suite', 400.00, TRUE, 'WiFi, TV, AC, Beach View, Private Pool'),
(10, 'Double', 180.00, TRUE, 'WiFi, TV, AC, Thames View'),
(11, 'Suite', 600.00, TRUE, 'WiFi, TV, AC, Beach View, Private Pool'),
(12, 'Double', 280.00, TRUE, 'WiFi, TV, AC, Thames View');

INSERT INTO food_menu (establishment_id, name, cuisine, rating, price, description) VALUES
(2, 'Croissant & Coffee', 'French', 4.8, 8.50, 'Fresh buttery croissant with espresso'),
(2, 'French Onion Soup', 'French', 4.7, 12.00, 'Classic French soup with cheese'),
(3, 'Coq au Vin', 'French', 4.9, 35.00, 'Chicken braised in red wine'),
(3, 'Beef Bourguignon', 'French', 4.8, 42.00, 'Tender beef stew with vegetables'),
(5, 'Sushi Platter', 'Japanese', 5.0, 45.00, 'Assorted fresh sushi and sashimi'),
(5, 'Ramen Bowl', 'Japanese', 4.8, 18.00, 'Rich tonkotsu ramen with pork'),
(7, 'New York Pizza', 'American', 4.5, 15.00, 'Classic NY style pizza slice'),
(7, 'Burger Deluxe', 'American', 4.6, 22.00, 'Gourmet burger with fries'),
(9, 'Nasi Goreng', 'Indonesian', 4.7, 12.00, 'Indonesian fried rice'),
(9, 'Satay Platter', 'Indonesian', 4.6, 18.00, 'Grilled meat skewers with peanut sauce'),
(10, 'Shawarma Royale', 'Middle Eastern', 4.8, 22.00, 'Grilled chicken wrap with tahini sauce'),
(13, 'Lamb Machboos', 'Arabic', 4.7, 28.00, 'Traditional spiced rice with lamb and herbs'),
(13, 'Falafel Delight', 'Vegetarian', 4.5, 15.00, 'Crispy chickpea patties served with hummus');

INSERT INTO attractions (city_id, name, category, entry_fee, ratings, about_attraction, opening_hours) VALUES
(1, 'Eiffel Tower', 'Monument', 25.00, 4.8, 'Iconic iron lattice tower and symbol of Paris', '9:00 AM - 11:45 PM'),
(1, 'Louvre Museum', 'Museum', 17.00, 4.9, 'World famous art museum housing Mona Lisa', '9:00 AM - 6:00 PM'),
(1, 'Arc de Triomphe', 'Monument', 13.00, 4.7, 'Iconic arch honoring French soldiers', '10:00 AM - 10:30 PM'),
(2, 'Tokyo Skytree', 'Monument', 20.00, 4.7, 'Tallest structure in Japan with observation decks', '8:00 AM - 10:00 PM'),
(2, 'Senso-ji Temple', 'Temple', 0.00, 4.8, 'Ancient Buddhist temple in Asakusa', '6:00 AM - 5:00 PM'),
(3, 'Statue of Liberty', 'Monument', 23.50, 4.8, 'Symbol of freedom and democracy', '9:00 AM - 5:00 PM'),
(3, 'Central Park', 'Park', 0.00, 4.9, 'Massive urban park in Manhattan', '6:00 AM - 1:00 AM'),
(4, 'Tanah Lot Temple', 'Temple', 5.00, 4.6, 'Ancient Hindu shrine on a rock formation', '7:00 AM - 7:00 PM'),
(4, 'Ubud Monkey Forest', 'Nature', 8.00, 4.5, 'Sacred forest sanctuary with monkeys', '8:30 AM - 6:00 PM'),
(5, 'Big Ben', 'Monument', 15.00, 4.8, 'Iconic clock tower of Westminster', '9:00 AM - 5:00 PM'),
(5, 'British Museum', 'Museum', 0.00, 4.9, 'World-famous museum of human history', '10:00 AM - 5:00 PM'),
(6, 'Burj Khalifa', 'Monument', 35.00, 4.9, 'Tallest skyscraper in the world', '9:00 AM - 10:00 PM'),
(6, 'Dubai Mall Aquarium', 'Aquarium', 25.00, 4.8, 'Massive underwater zoo inside Dubai Mall', '10:00 AM - 11:00 PM'),
(6, 'Dubai Museum', 'Museum', 10.00, 4.5, 'Historical exhibits inside Al Fahidi Fort', '8:30 AM - 8:30 PM');

INSERT INTO transport (mode, from_city_id, destination_city_id, cost, duration, seats_available, departure_time) VALUES
('Flight', 1, 2, 850.00, '14h', 200, '10:00 AM'),
('Flight', 1, 3, 500.00, '8h', 180, '2:00 PM'),
('Train', 1, 5, 150.00, '2h 30m', 300, '9:00 AM'),
('Flight', 1, 6, 650.00, '7h', 180, '10:00 AM'),
('Flight', 2, 1, 850.00, '14h', 200, '6:00 PM'),
('Flight', 2, 3, 780.00, '13h', 220, '11:00 AM'),
('Flight', 2, 4, 350.00, '7h', 150, '8:00 AM'),
('Flight', 3, 1, 500.00, '8h', 180, '5:00 PM'),
('Flight', 3, 2, 780.00, '13h', 220, '12:00 PM'),
('Flight', 3, 5, 400.00, '7h', 200, '9:00 AM'),
('Flight', 4, 2, 350.00, '7h', 150, '3:00 PM'),
('Flight', 4, 1, 650.00, '16h', 160, '10:00 AM'),
('Train', 5, 1, 150.00, '2h 30m', 300, '11:00 AM'),
('Flight', 5, 3, 400.00, '7h', 200, '1:00 PM'),
('Flight', 5, 2, 700.00, '12h', 180, '7:00 AM'),
('Flight', 5, 6, 7.00, '7h', 190, '7:00 AM'),
('Flight', 6, 1, 650.00, '7h', 180, '10:00 AM'),
('Flight', 6, 5, 7.00, '7h', 190, '7:00 AM'),
('Train', 6, 6, 0.00, '1h', 300, '6:00 AM');

-- ==============================================
-- 3. MINIMAL FUNCTIONS (3)
-- ==============================================
DELIMITER $$

CREATE FUNCTION fn_transport_cost(tid INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE c DECIMAL(10,2);
    SELECT cost INTO c FROM transport WHERE transport_id = tid;
    RETURN c;
END $$

CREATE FUNCTION fn_room_cost(rid INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE p DECIMAL(10,2);
    SELECT price_per_night INTO p FROM rooms WHERE room_id = rid;
    RETURN p;
END $$

CREATE FUNCTION fn_attraction_cost(aid INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE e DECIMAL(10,2);
    SELECT entry_fee INTO e FROM attractions WHERE attraction_id = aid;
    RETURN e;
END $$

-- ==============================================
-- ⭐ NEW FUNCTION: FOOD PRICE
-- ==============================================

CREATE FUNCTION fn_food_price(fid INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE f DECIMAL(10,2);
    SELECT price INTO f FROM food_menu WHERE food_id = fid;
    RETURN f;
END $$

DELIMITER ;

-- ==============================================
-- 4. MINIMAL TRIGGERS (3)
-- ==============================================
DELIMITER $$

CREATE TRIGGER trg_transport_booking
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
    IF NEW.service_type = 'Transport' THEN
        UPDATE transport
        SET seats_available = seats_available - 1
        WHERE transport_id = NEW.service_id;
    END IF;
END $$

CREATE TRIGGER trg_room_unavailable
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
    IF NEW.service_type = 'Room' THEN
        UPDATE rooms
        SET availability = FALSE
        WHERE room_id = NEW.service_id;
    END IF;
END $$

CREATE TRIGGER trg_review_rating_limit
BEFORE INSERT ON reviews
FOR EACH ROW
BEGIN
    IF NEW.ratings > 5 THEN SET NEW.ratings = 5; END IF;
    IF NEW.ratings < 0 THEN SET NEW.ratings = 0; END IF;
END $$

DELIMITER ;

-- ==============================================
-- 5. MINIMAL PROCEDURES (3)
-- ==============================================
DELIMITER $$

CREATE PROCEDURE sp_book_transport(IN uid INT, IN tid INT)
BEGIN
    INSERT INTO bookings (user_id, total_cost, service_type, service_id)
    VALUES (uid, fn_transport_cost(tid), 'Transport', tid);
END $$

CREATE PROCEDURE sp_book_room(IN uid INT, IN rid INT)
BEGIN
    INSERT INTO bookings (user_id, total_cost, service_type, service_id)
    VALUES (uid, fn_room_cost(rid), 'Room', rid);
END $$

CREATE PROCEDURE sp_book_attraction(IN uid INT, IN aid INT)
BEGIN
    INSERT INTO bookings (user_id, total_cost, service_type, service_id)
    VALUES (uid, fn_attraction_cost(aid), 'Attraction', aid);
END $$

-- ==============================================
-- ⭐ NEW PROCEDURE: BOOK FOOD
-- ==============================================

CREATE PROCEDURE sp_book_food(IN uid INT, IN fid INT)
BEGIN
    INSERT INTO bookings (user_id, total_cost, service_type, service_id, booking_details)
    VALUES (uid, fn_food_price(fid), 'Food', fid, 'Food Order Booking');
END $$

DELIMITER ;

