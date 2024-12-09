import hashlib, datetime, os
from flask import Flask, request, jsonify
from pymongo import MongoClient
from transformers import pipeline
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity

app = Flask(__name__)
app.config['JWT_SECRET_KEY'] = b'\xeeJ\xab\xe2S\xf9\x1d\x13\xc9\x18]j\x1e*\xb4c'
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = datetime.timedelta(days=2)
os.environ['HF_DATASETS_OFFLINE ']="1"
os.environ['TRANSFORMERS_OFFLINE']="1"

jwt = JWTManager(app)
classifier = pipeline("zero-shot-classification",
                      model="vicgalle/xlm-roberta-large-xnli-anli")
candidate_labels = ['tos', 'dolor de garganta', 'dolor de cabeza', 'ojos irritados']
client = MongoClient("mongodb://localhost:27017/") # connection string
db = client["demo"]
users_collection = db["users"]
messages_collection = db["messages"]

@app.route("/register", methods=["POST"])
def register():
    new_user = request.get_json() # store the json body request
    new_user["password"] = hashlib.sha256(new_user["password"].encode("utf-8")).hexdigest() # encrpt password
    doc = users_collection.find_one({"username": new_user["username"]}) # check if user exist
    if not doc:
        users_collection.insert_one(new_user)
        return jsonify({'msg': 'User created successfully'}), 201
    else:
        return jsonify({'msg': 'Username already exists'}), 409

@app.route("/login", methods=["POST"])
def login():
    login_details = request.get_json() # store the json body request
    user_from_db = users_collection.find_one({'username': login_details['username']})  # search for user in database

    if user_from_db:
        encrpted_password = hashlib.sha256(login_details['password'].encode("utf-8")).hexdigest()
        if encrpted_password == user_from_db['password']:
            access_token = create_access_token(identity=user_from_db['username']) # create jwt token
            return jsonify(access_token=access_token), 200

    return jsonify({'user': 'The username or password is incorrect'}), 401

@app.route('/send', methods = ['GET', 'POST'])
def send_msg():
    json_file = {}
    if request.method == 'POST' and request.json:
        new_msg = request.get_json()
        sequence_to_classify = request.json["message"]
        data = classifier(sequence_to_classify, candidate_labels)
        scores = data['scores']
        ind_score = scores.index(max(scores))
        clase = data['labels'][ind_score]
        json_file['class'] = clase
        new_msg['class'] = clase
        dt = datetime.datetime.now()
        new_msg['timestamp'] = dt
        messages_collection.insert_one(new_msg)
        return jsonify(json_file)
    else:
        return jsonify(json_file)


@app.route('/pollution_data', methods=['GET'])
def get_pollution_data():
    pollution_data = []
    documents = db.pollution_levels.find({}, {"_id": 0, "station_id": 0})  # Exclude _id and station_id

    for doc in documents:
        pollution_data.append(doc)

    return jsonify(pollution_data), 200


# Test route
@app.route('/test_pollution_data', methods=['GET'])
def test_pollution_data():
    data = get_pollution_data()
    print(data)
    return data



if __name__ == '__main__':
    app.run(debug=True)
