from flask import Flask, request, abort, jsonify
from flask_cors import CORS
from pymongo import MongoClient
from functools import wraps
import os
from dotenv import load_dotenv

load_dotenv(".env")

API_KEY = os.getenv("LOG_DB_API_KEY")
DATABASE_URI = os.getenv("MONGO_URI")

app = Flask(__name__)
CORS(app)

# Connect to MongoDB Atlas
client = MongoClient(DATABASE_URI)
db = client['game_data']  # Database name
session_ids = db["session_ids"]

# API key decorator
def require_api_key(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        key = request.headers.get("X-Log-Db-Api-Key")
        if key and key == API_KEY:
            return f(*args, **kwargs)
        else:
            abort(401, description="Unauthorized: Invalid API key")
    return decorated

# Session id counter already in the DB
def get_next_session_id():
    counter = db.counters.find_one_and_update(
        {"_id": "session_id"},
        {"$inc": {"next_id": 1}},
        return_document=True
    )
    return counter["next_id"]

# Wake API host and check if running
@app.route('/', methods=['GET'])
def home():
    return jsonify({"message": "Database API is running!"}), 200

# Examine request headers
@app.route('/debug_headers', methods=['POST', 'GET'])
def debug_headers():
    print(dict(request.headers)) # REMOVE AFTER LIVE TEST
    return jsonify(dict(request.headers)), 200

# Create a testing session
@app.route('/create_test_session', methods=['POST'])
@require_api_key
def create_session():
    data = request.json
    if not data or "guid" not in data:
        return jsonify({"error": "Missing 'guid' in request"}), 400

    guid = data["guid"]

    session_ids.insert_one({
        "session_id": -1,
        "guid": guid
    })

    return jsonify({"session_id": -1, "guid": guid}), 201

# Create a new session
@app.route('/create_session', methods=['POST'])
@require_api_key
def create_test_session():
    data = request.json
    if not data or "guid" not in data:
        return jsonify({"error": "Missing 'guid' in request"}), 400

    guid = data["guid"]
    new_id = get_next_session_id()

    session_ids.insert_one({
        "session_id": new_id,
        "guid": guid
    })

    return jsonify({"session_id": new_id, "guid": guid}), 201

# Add a new log to a session
@app.route('/add_log/<session_id>', methods=['POST'])
@require_api_key
def add_action(session_id):
    action_data = request.json
    if not action_data:
        return jsonify({"error": "Missing action data"}), 400

    collection = db[f"session_{session_id}"]
    collection.insert_one(action_data)

    return jsonify({"message": f"Action added to session {session_id}"}), 201

# Get all session IDs
@app.route('/get_session_ids', methods=['GET'])
@require_api_key
def get_session_ids():
    sessions = list(session_ids.find({}, {"_id": 0}))
    return jsonify(sessions), 200

@app.route('/get_session_data/<session_id>', methods=['GET'])
@require_api_key
def get_session_data(session_id):
    collection = db.get_collection(f"session_{session_id}")
    if not collection:
        return jsonify({"error": f"No data found for session {session_id}"}), 404

    logs = list(collection.find({}, {"_id": 0}))
    return jsonify({
        "session_id": session_id,
        "logs": logs
    }), 200

@app.route('/get_all_session_data', methods=['GET'])
@require_api_key
def get_all_session_data():
    all_data = []
    sessions = list(session_ids.find({}, {"_id": 0}))

    for session in sessions:
        sid = session["session_id"]
        collection = db.get_collection(f"session_{sid}")
        logs = list(collection.find({}, {"_id": 0}))
        all_data.append({
            "session_id": sid,
            "guid": session["guid"],
            "logs": logs
        })

    return jsonify(all_data), 200

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)