# Py_Hostel - Smart Hostel Management System

Py_Hostel is a web-based hostel management system with role-based dashboards for Admin, Student, and Teacher users.

## Tech Stack
- Backend: Python, Flask, Flask-SocketIO
- Database: PostgreSQL
- Frontend: HTML, CSS, Jinja2 templates, JavaScript
- Libraries: psycopg2-binary, ReportLab

## Local Setup (PostgreSQL)

### Prerequisites
1. Python 3.10+
2. PostgreSQL 13+
3. No external PDF binary is needed; receipt PDFs are generated with ReportLab

### 1. Install dependencies
```bash
pip install -r requirements.txt
```

### 2. Create and seed database
Create a PostgreSQL database named nasa_home, then run:
```bash
psql -d nasa_home -f schema_postgres.sql
```

### 3. Configure environment
Copy .env.example to .env and set values.

Recommended (single URL):
```env
DATABASE_URL=postgresql://postgres:your_password@localhost:5432/nasa_home
SECRET_KEY=replace-with-a-long-random-value
ADMIN_SECRET=replace-with-admin-secret
```

Alternative (split variables):
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=nasa_home
SECRET_KEY=replace-with-a-long-random-value
ADMIN_SECRET=replace-with-admin-secret
```

### 4. Run app locally
```bash
python app.py
```

Open http://127.0.0.1:5000/

## Render Deployment

This repository includes both Procfile and render.yaml.

### Option A: Blueprint deploy (render.yaml)
1. Push the repository to GitHub.
2. In Render, create a new Blueprint and select the repository.
3. Set ADMIN_SECRET from Render dashboard.
4. Apply schema_postgres.sql to the Render PostgreSQL database once.

### Option B: Manual Web Service
1. Create a new Web Service from this repository.
2. Build command: pip install -r requirements.txt
3. Start command: gunicorn --worker-class eventlet --workers 1 --bind 0.0.0.0:$PORT app:app
4. Add environment variables:
   - DATABASE_URL (from Render PostgreSQL)
   - SECRET_KEY
   - ADMIN_SECRET
   - RENDER=1

## Demo Accounts
After running schema_postgres.sql:
- admin@nasa.com / admin123
- student1@nasa.com / student123
- teacher1@nasa.com / teacher123