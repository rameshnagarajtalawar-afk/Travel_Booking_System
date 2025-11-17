##Travel Booking System 🌍

A full-stack web application that allows users to explore global destinations, book travel services, and manage their trips.
The system integrates React.js, Node.js (Express), and MySQL to provide a complete travel-booking experience.

#🚀 Features
User Module

Secure user registration and login (JWT authentication)

Profile-based dashboard

View and manage bookings

Travel Services

Browse cities with images, descriptions, and best seasons

Book rooms, transport, attractions, food

Real-time availability updates using database triggers

Reviews System

Post reviews with rating slider

Filter reviews by category (Food, Room, Attraction, Transport)

View reviews from other travelers

#🛠 Tech Stack
Frontend

React.js

Axios (API communication)

CSS for UI styling

Backend

Node.js

Express.js

JWT (Authentication)

Bcrypt (Password hashing)

Database

MySQL

Stored Procedures

Triggers

Functions

#📁 Project Structure
Travel_Booking_System/
│── backend/        # Node.js API
│── frontend/       # React application
│── database.sql    # MySQL schema + sample data
│── README.md       # Project documentation

#🧪 Key Functionalities

Fetching dynamic city content with images

Booking confirmation workflow

Updating transport seats automatically

Automatically marking rooms unavailable

Rating validation using triggers

Stored procedures for booking automation

#📌 How to Run the Project
Backend
cd backend
npm install
node server.js

Frontend
cd frontend
npm install
npm start

#📖 Future Enhancements

Admin dashboard for managing cities and services

Payment gateway integration

Personalized recommendations using ML
