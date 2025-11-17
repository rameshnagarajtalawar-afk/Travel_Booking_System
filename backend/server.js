const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = 5000;
const JWT_SECRET = 'your-secret-key-change-in-production';

// Middleware
app.use(cors());
app.use(express.json());

// Database Connection Pool
const pool = mysql.createPool({
  host: '127.0.0.1',
  user: 'root',
  password: '87225',
  database: 'travel_booking',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Test database connection
pool.getConnection()
  .then(connection => {
    console.log('✓ Database connected successfully');
    connection.release();
  })
  .catch(err => {
    console.error('✗ Database connection failed:', err.message);
  });

// Auth Middleware
const authenticateToken = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Access denied' });
  
  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid token' });
    req.user = user;
    next();
  });
};

// ============ AUTH ROUTES ============

// Register
app.post('/api/auth/register', async (req, res) => {
  try {
    const { name, email_id, password, home_city, budget } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);
    
    const [result] = await pool.execute(
      'INSERT INTO users (name, email_id, password, home_city, budget) VALUES (?, ?, ?, ?, ?)',
      [name, email_id, hashedPassword, home_city, budget]
    );
    
    res.status(201).json({ message: 'User registered successfully', userId: result.insertId });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      res.status(400).json({ error: 'Email already exists' });
    } else {
      res.status(500).json({ error: error.message });
    }
  }
});

// Login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email_id, password } = req.body;
    
    const [users] = await pool.execute('SELECT * FROM users WHERE email_id = ?', [email_id]);
    if (users.length === 0) return res.status(401).json({ error: 'Invalid credentials' });
    
    const user = users[0];
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) return res.status(401).json({ error: 'Invalid credentials' });
    
    const token = jwt.sign({ userId: user.user_id, email: user.email_id }, JWT_SECRET);
    res.json({ 
      token, 
      user: { 
        id: user.user_id, 
        name: user.name, 
        email: user.email_id,
        home_city: user.home_city,
        budget: user.budget
      } 
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ CITIES ROUTES ============

app.get('/api/cities', async (req, res) => {
  try {
    const [cities] = await pool.execute('SELECT * FROM cities');
    res.json(cities);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/cities/:id', async (req, res) => {
  try {
    const [cities] = await pool.execute('SELECT * FROM cities WHERE city_id = ?', [req.params.id]);
    if (cities.length === 0) return res.status(404).json({ error: 'City not found' });
    res.json(cities[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ TRANSPORT ROUTES ============

app.get('/api/transport', async (req, res) => {
  try {
    const { fromCity, toCity } = req.query;
    let query = `
      SELECT t.*, 
             c1.name as from_city_name, c1.country as from_country,
             c2.name as destination_name, c2.country as destination_country
      FROM transport t 
      LEFT JOIN cities c1 ON t.from_city_id = c1.city_id
      LEFT JOIN cities c2 ON t.destination_city_id = c2.city_id
      WHERE 1=1
    `;
    const params = [];
    
    if (fromCity) {
      query += ' AND t.from_city_id = ?';
      params.push(fromCity);
    }
    if (toCity) {
      query += ' AND t.destination_city_id = ?';
      params.push(toCity);
    }
    
    const [transport] = await pool.execute(query, params);
    res.json(transport);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ ROOMS ROUTES ============

app.get('/api/rooms', async (req, res) => {
  try {
    const { cityId, establishmentId } = req.query;
    let query = `
      SELECT r.*, e.name as establishment_name, e.rating as establishment_rating,
             e.address, c.name as city_name
      FROM rooms r 
      LEFT JOIN establishments e ON r.establishment_id = e.establishment_id 
      LEFT JOIN cities c ON e.city_id = c.city_id
      WHERE r.availability = TRUE AND e.type = 'Hotel'
    `;
    const params = [];
    
    if (cityId) {
      query += ' AND e.city_id = ?';
      params.push(cityId);
    }
    if (establishmentId) {
      query += ' AND r.establishment_id = ?';
      params.push(establishmentId);
    }
    
    const [rooms] = await pool.execute(query, params);
    res.json(rooms);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/rooms/:id', async (req, res) => {
  try {
    const [rooms] = await pool.execute(`
      SELECT r.*, e.name as establishment_name, e.rating, e.address,
             c.name as city_name, c.country
      FROM rooms r
      LEFT JOIN establishments e ON r.establishment_id = e.establishment_id
      LEFT JOIN cities c ON e.city_id = c.city_id
      WHERE r.room_id = ?
    `, [req.params.id]);
    
    if (rooms.length === 0) return res.status(404).json({ error: 'Room not found' });
    res.json(rooms[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ FOOD ROUTES ============

app.get('/api/food', async (req, res) => {
  try {
    const { cityId, establishmentId } = req.query;
    let query = `
      SELECT f.*, e.name as establishment_name, e.type as establishment_type,
             e.rating as establishment_rating, e.address,
             c.name as city_name, c.country
      FROM food_menu f 
      LEFT JOIN establishments e ON f.establishment_id = e.establishment_id 
      LEFT JOIN cities c ON e.city_id = c.city_id
      WHERE e.type IN ('Restaurant', 'Cafe', 'Bar')
    `;
    const params = [];
    
    if (cityId) {
      query += ' AND e.city_id = ?';
      params.push(cityId);
    }
    if (establishmentId) {
      query += ' AND f.establishment_id = ?';
      params.push(establishmentId);
    }
    
    const [food] = await pool.execute(query, params);
    res.json(food);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/food/:id', async (req, res) => {
  try {
    const [food] = await pool.execute(`
      SELECT f.*, e.name as establishment_name, e.type, e.rating as establishment_rating,
             e.address, c.name as city_name, c.country
      FROM food_menu f
      LEFT JOIN establishments e ON f.establishment_id = e.establishment_id
      LEFT JOIN cities c ON e.city_id = c.city_id
      WHERE f.food_id = ?
    `, [req.params.id]);
    
    if (food.length === 0) return res.status(404).json({ error: 'Food item not found' });
    res.json(food[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ ATTRACTIONS ROUTES ============

app.get('/api/attractions', async (req, res) => {
  try {
    const { cityId } = req.query;
    let query = `
      SELECT a.*, c.name as city_name, c.country 
      FROM attractions a 
      LEFT JOIN cities c ON a.city_id = c.city_id
    `;
    const params = [];
    
    if (cityId) {
      query += ' WHERE a.city_id = ?';
      params.push(cityId);
    }
    
    const [attractions] = await pool.execute(query, params);
    res.json(attractions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/attractions/:id', async (req, res) => {
  try {
    const [attractions] = await pool.execute(`
      SELECT a.*, c.name as city_name, c.country
      FROM attractions a
      LEFT JOIN cities c ON a.city_id = c.city_id
      WHERE a.attraction_id = ?
    `, [req.params.id]);
    
    if (attractions.length === 0) return res.status(404).json({ error: 'Attraction not found' });
    res.json(attractions[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============ BOOKINGS ROUTES ============

app.post('/api/bookings', authenticateToken, async (req, res) => {
  try {
    const { service_type, service_id, total_cost, booking_details } = req.body;
    const userId = req.user.userId;
    
    const [result] = await pool.execute(
      'INSERT INTO bookings (user_id, service_type, service_id, total_cost, booking_details, status) VALUES (?, ?, ?, ?, ?, ?)',
      [userId, service_type, service_id, total_cost, JSON.stringify(booking_details), 'Confirmed']
    );
    
    res.status(201).json({ 
      message: 'Booking confirmed successfully', 
      bookingId: result.insertId 
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/bookings/user', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const [bookings] = await pool.execute(`
      SELECT b.* 
      FROM bookings b 
      WHERE b.user_id = ? 
      ORDER BY b.booking_date DESC
    `, [userId]);
    
    // Parse booking_details JSON
    const bookingsWithDetails = bookings.map(booking => ({
      ...booking,
      booking_details: JSON.parse(booking.booking_details || '{}')
    }));
    
    res.json(bookingsWithDetails);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/bookings/:id', authenticateToken, async (req, res) => {
  try {
    const [bookings] = await pool.execute(`
      SELECT b.*
      FROM bookings b
      WHERE b.booking_id = ? AND b.user_id = ?
    `, [req.params.id, req.user.userId]);
    
    if (bookings.length === 0) return res.status(404).json({ error: 'Booking not found' });
    
    const booking = {
      ...bookings[0],
      booking_details: JSON.parse(bookings[0].booking_details || '{}')
    };
    
    res.json(booking);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


// ============ REVIEWS ROUTES ============

app.post('/api/reviews', authenticateToken, async (req, res) => {
  try {
    const { category, place_id, ratings, comments } = req.body;
    const userId = req.user.userId;

    await pool.execute(
      `INSERT INTO reviews (user_id, category, place_id, ratings, comments)
       VALUES (?, ?, ?, ?, ?)`,
      [userId, category, place_id, ratings, comments]
    );

    res.status(201).json({ message: 'Review submitted successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/reviews', async (req, res) => {
  try {
    const { category } = req.query;

    let query = `
      SELECT 
        r.review_id,
        r.category,
        r.ratings,
        r.comments,
        r.place_id,
        r.created_at,
        u.name AS user_name,
        CASE 
          WHEN r.category = 'Attraction' THEN a.name
          WHEN r.category IN ('Food', 'Room') THEN e.name
          WHEN r.category = 'Transport' THEN 
            CONCAT(t.mode, ': ', fc.name, ' → ', dc.name)
        END AS place_name
      FROM reviews r
      LEFT JOIN users u ON r.user_id = u.user_id
      LEFT JOIN attractions a ON a.attraction_id = r.place_id AND r.category = 'Attraction'
      LEFT JOIN establishments e ON e.establishment_id = r.place_id AND r.category IN ('Food', 'Room')
      LEFT JOIN transport t ON t.transport_id = r.place_id AND r.category = 'Transport'
      LEFT JOIN cities fc ON fc.city_id = t.from_city_id
      LEFT JOIN cities dc ON dc.city_id = t.destination_city_id
      WHERE 1=1
    `;

    const params = [];

    if (category) {
      query += ' AND r.category = ?';
      params.push(category);
    }

    query += ' ORDER BY r.created_at DESC';

    const [reviews] = await pool.execute(query, params);
    res.json(reviews);

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/places', async (req, res) => {
  const { category } = req.query;
  let query = "";

  if (category === 'Attraction') {
    query = "SELECT attraction_id AS id, name FROM attractions";
  } 
  else if (category === 'Food') {
    query = "SELECT establishment_id AS id, name FROM establishments WHERE type IN ('Restaurant', 'Cafe', 'Bar')";
  } 
  else if (category === 'Room') {
    query = "SELECT establishment_id AS id, name FROM establishments WHERE type = 'Hotel'";
  } 
  else if (category === 'Transport') {
    query = `
      SELECT 
        t.transport_id AS id,
        CONCAT(
          t.mode, ': ',
          (SELECT name FROM cities WHERE city_id = t.from_city_id),
          ' → ',
          (SELECT name FROM cities WHERE city_id = t.destination_city_id)
        ) AS name
      FROM transport t
    `;
  } 
  else {
    return res.status(400).json({ error: "Invalid category" });
  }

  const [places] = await pool.execute(query);
  res.json(places);
});

// Start server
app.listen(PORT, () => {
  console.log(`✓ Server running on http://localhost:${PORT}`);
});
