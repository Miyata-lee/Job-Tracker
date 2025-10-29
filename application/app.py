# application/app.py
from flask import Flask, render_template, request, jsonify, session, redirect, url_for
import mysql.connector
from mysql.connector import Error
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
from flask_cors import CORS
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__, template_folder="frontend-app/templates")
app.secret_key = os.getenv('SECRET_KEY')

# Optional: restrict to your CloudFront domain in prod (comma-separated)
CORS(app, origins=os.getenv('CORS_ORIGINS', '*'))

db_config = {
    'host': os.getenv('DB_HOST'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'database': os.getenv('DB_NAME')  # ensure this matches RDS script/workflow
}

def get_db_connection():
    try:
        return mysql.connector.connect(**db_config)
    except Error as e:
        print(f"Database connection error: {e}")
        return None

@app.route('/health')
def health():
    conn = None
    try:
        conn = get_db_connection()
        ok = conn is not None and conn.is_connected()
        status = {'app': 'ok', 'db': 'ok' if ok else 'fail'}
        return jsonify(status), 200 if ok else 500
    finally:
        if conn:
            conn.close()

@app.route('/')
def index():
    if 'user_id' in session:
        return redirect(url_for('dashboard'))
    return redirect(url_for('auth'))

@app.route('/auth')
def auth():
    return render_template('index.html')

@app.route('/api/signup', methods=['POST'])
def signup():
    conn = None
    try:
        data = request.get_json()
        username = data.get('username', '').strip()
        email = data.get('email', '').strip()
        password = data.get('password', '')
        if not username or not email or not password:
            return jsonify({'success': False, 'message': 'All fields required'}), 400
        if len(password) < 6:
            return jsonify({'success': False, 'message': 'Password must be at least 6 characters'}), 400
        conn = get_db_connection()
        if not conn:
            return jsonify({'success': False, 'message': 'Database connection error'}), 500
        cursor = conn.cursor(dictionary=True)
        cursor.execute('SELECT id FROM users WHERE username = %s OR email = %s', (username, email))
        if cursor.fetchone():
            return jsonify({'success': False, 'message': 'User already exists'}), 400
        hashed_password = generate_password_hash(password)
        cursor.execute(
            'INSERT INTO users (username, email, password) VALUES (%s, %s, %s)',
            (username, email, hashed_password)
        )
        conn.commit()
        return jsonify({'success': True, 'message': 'Signup successful! Please login.'}), 201
    except Exception as e:
        print(f"Signup error: {e}")
        return jsonify({'success': False, 'message': 'Signup failed'}), 500
    finally:
        if conn:
            conn.close()

@app.route('/api/login', methods=['POST'])
def login():
    conn = None
    try:
        data = request.get_json()
        username = data.get('username', '').strip()
        password = data.get('password', '')
        if not username or not password:
            return jsonify({'success': False, 'message': 'Username and password required'}), 400
        conn = get_db_connection()
        if not conn:
            return jsonify({'success': False, 'message': 'Database connection error'}), 500
        cursor = conn.cursor(dictionary=True)
        cursor.execute('SELECT id, username, password FROM users WHERE username = %s', (username,))
        user = cursor.fetchone()
        if not user or not check_password_hash(user['password'], password):
            return jsonify({'success': False, 'message': 'Invalid credentials'}), 401
        session['user_id'] = user['id']
        session['username'] = user['username']
        return jsonify({'success': True, 'message': 'Login successful', 'user': user['username']}), 200
    except Exception as e:
        print(f"Login error: {e}")
        return jsonify({'success': False, 'message': 'Login failed'}), 500
    finally:
        if conn:
            conn.close()

@app.route('/api/logout', methods=['POST'])
def logout():
    session.clear()
    return jsonify({'success': True, 'message': 'Logged out successfully'}), 200

@app.route('/dashboard')
def dashboard():
    if 'user_id' not in session:
        return redirect(url_for('auth'))
    return render_template('dashboard.html', username=session['username'])

@app.route('/api/jobs', methods=['GET', 'POST'])
def manage_jobs():
    if 'user_id' not in session:
        return jsonify({'success': False, 'message': 'Not authenticated'}), 401
    user_id = session['user_id']
    conn = None
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({'success': False, 'message': 'Database error'}), 500
        cursor = conn.cursor(dictionary=True)
        if request.method == 'POST':
            data = request.get_json()
            cursor.execute(
                '''INSERT INTO jobs (user_id, company_name, position, status, date_applied, notes)
                   VALUES (%s, %s, %s, %s, %s, %s)''',
                (user_id, data['company_name'], data['position'], data['status'],
                 data['date_applied'], data.get('notes', ''))
            )
            conn.commit()
            return jsonify({'success': True, 'message': 'Job added successfully'}), 201
        else:
            cursor.execute(
                '''SELECT id, company_name, position, status, date_applied, notes
                   FROM jobs WHERE user_id = %s ORDER BY date_applied DESC''',
                (user_id,)
            )
            jobs = cursor.fetchall()
            return jsonify({'success': True, 'jobs': jobs}), 200
    except Exception as e:
        print(f"Jobs error: {e}")
        return jsonify({'success': False, 'message': 'Error'}), 500
    finally:
        if conn:
            conn.close()

@app.route('/api/jobs/<int:job_id>', methods=['GET', 'PUT', 'DELETE'])
def job_detail(job_id):
    if 'user_id' not in session:
        return jsonify({'success': False, 'message': 'Not authenticated'}), 401
    user_id = session['user_id']
    conn = None
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({'success': False, 'message': 'Database error'}), 500
        cursor = conn.cursor(dictionary=True)
        if request.method == 'DELETE':
            cursor.execute('DELETE FROM jobs WHERE id = %s AND user_id = %s', (job_id, user_id))
            conn.commit()
            if cursor.rowcount == 0:
                return jsonify({'success': False, 'message': 'Job not found'}), 404
            return jsonify({'success': True, 'message': 'Job deleted'}), 200
        elif request.method == 'PUT':
            data = request.get_json()
            cursor.execute(
                '''UPDATE jobs SET company_name = %s, position = %s, status = %s,
                   date_applied = %s, notes = %s WHERE id = %s AND user_id = %s''',
                (data['company_name'], data['position'], data['status'],
                 data['date_applied'], data.get('notes', ''), job_id, user_id)
            )
            conn.commit()
            if cursor.rowcount == 0:
                return jsonify({'success': False, 'message': 'Job not found'}), 404
            return jsonify({'success': True, 'message': 'Job updated'}), 200
        else:
            cursor.execute('SELECT * FROM jobs WHERE id = %s AND user_id = %s', (job_id, user_id))
            job = cursor.fetchone()
            if not job:
                return jsonify({'success': False, 'message': 'Job not found'}), 404
            return jsonify({'success': True, 'job': job}), 200
    except Exception as e:
        print(f"Job detail error: {e}")
        return jsonify({'success': False, 'message': 'Error'}), 500
    finally:
        if conn:
            conn.close()

@app.errorhandler(404)
def not_found(error):
    return jsonify({'success': False, 'message': 'Not found'}), 404

@app.errorhandler(500)
def server_error(error):
    return jsonify({'success': False, 'message': 'Server error'}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
