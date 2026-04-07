-- PostgreSQL schema for Py_Hostel
-- Run this file on your target database (for example: nasa_home).

CREATE TABLE IF NOT EXISTS Users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('Admin', 'Student', 'Teacher')),
    full_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Rooms (
    id SERIAL PRIMARY KEY,
    room_number VARCHAR(10) UNIQUE NOT NULL,
    capacity INT NOT NULL,
    teacher_id INT NULL,
    FOREIGN KEY (teacher_id) REFERENCES Users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Room_Assignments (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    room_id INT NOT NULL,
    assigned_date DATE NOT NULL,
    FOREIGN KEY (student_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES Rooms(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Food_Items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(20) NOT NULL CHECK (category IN ('Non-Veg', 'Veg')),
    price NUMERIC(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS Orders (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Order_Details (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    food_item_id INT NOT NULL,
    quantity INT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(id) ON DELETE CASCADE,
    FOREIGN KEY (food_item_id) REFERENCES Food_Items(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Payments (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    payment_type VARCHAR(20) NOT NULL CHECK (payment_type IN ('Meal', 'Hall Fee', 'Penalty')),
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Paid')),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Complaints (
    id SERIAL PRIMARY KEY,
    student_id INT NULL,
    room_id INT NULL,
    description TEXT NOT NULL,
    is_anonymous BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Reviewed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES Rooms(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Maintenance_Requests (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    room_id INT NOT NULL,
    issue TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'In Progress', 'Resolved')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES Rooms(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Notifications (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_read_created
ON Notifications (user_id, is_read, created_at);

CREATE TABLE IF NOT EXISTS Notices (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    target_role VARCHAR(20) DEFAULT 'All' CHECK (target_role IN ('All', 'Admin', 'Student', 'Teacher')),
    is_active BOOLEAN DEFAULT TRUE,
    is_pinned BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP NULL,
    created_by INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES Users(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_notices_visibility
ON Notices (is_active, target_role, is_pinned, created_at);

CREATE INDEX IF NOT EXISTS idx_notices_expires
ON Notices (expires_at);

CREATE TABLE IF NOT EXISTS Reading_Room_Bookings (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    booking_date DATE NOT NULL,
    time_slot VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Users(id) ON DELETE CASCADE,
    UNIQUE (booking_date, time_slot, student_id)
);

CREATE TABLE IF NOT EXISTS Chat_Messages (
    id SERIAL PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    message TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES Users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Hall_Fees (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    due_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Unpaid' CHECK (status IN ('Unpaid', 'Paid')),
    paid_at TIMESTAMP NULL,
    FOREIGN KEY (student_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- Seed data with password hashes compatible with Werkzeug check_password_hash.
INSERT INTO Users (email, password, role, full_name)
VALUES
('admin@nasa.com', 'scrypt:32768:8:1$McPxAjnewG7WtM1g$db2b45eeeb43d89ee26d225ee6e774ed4e453a1ce92e8fe7ba35a8daae823636bdec385a376154f39e4de0447e3df7b32e0bc7cd4099164afb433f104b6e8c3c', 'Admin', 'System Admin'),
('student1@nasa.com', 'scrypt:32768:8:1$lA3G0Vqh4GX9dmeq$3d6d609ca0feaab5090a139772ab6068158338ee6942176ca1072b64445434f11616778abedfef05762d664f213d001b4d1f7e47ee7e351eb70a12ea01141f0a', 'Student', 'John Doe'),
('teacher1@nasa.com', 'scrypt:32768:8:1$CzCnffkabev1YaOm$6c54b147262e1e533c0440b6ff7221bb375847c19138d6b180102e6105e03db9b6b9045e2f659651df8ddd7aec2711da37cf8c08724d94f2e543c9b3071b5008', 'Teacher', 'Mr. Smith')
ON CONFLICT (email) DO NOTHING;

INSERT INTO Food_Items (name, category, price)
VALUES ('chicken curry', 'Non-Veg', 50.00)
ON CONFLICT (name) DO NOTHING;


INSERT INTO Rooms (room_number, capacity, teacher_id)
VALUES
('101', 2, (SELECT id FROM Users WHERE email = 'teacher1@nasa.com')),
('102', 2, NULL)
ON CONFLICT (room_number) DO NOTHING;

INSERT INTO Room_Assignments (student_id, room_id, assigned_date)
SELECT
    (SELECT id FROM Users WHERE email = 'student1@nasa.com'),
    (SELECT id FROM Rooms WHERE room_number = '101'),
    DATE '2023-09-01'
WHERE NOT EXISTS (
    SELECT 1
    FROM Room_Assignments
    WHERE student_id = (SELECT id FROM Users WHERE email = 'student1@nasa.com')
);
