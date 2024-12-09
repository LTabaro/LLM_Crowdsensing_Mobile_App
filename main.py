from flask import Flask, jsonify, request
import os
os.environ['HF_DATASETS_OFFLINE ']="1"
os.environ['TRANSFORMERS_OFFLINE']="1"
from transformers import pipeline
classifier = pipeline("zero-shot-classification",
                      model="vicgalle/xlm-roberta-large-xnli-anli")

app = Flask(__name__)

@app.route('/', methods = ['GET', 'POST'])
def hello_world():
    print(request.json)
    json_file = {}
    if request.method == 'POST' and request.json:
        sequence_to_classify = request.json["title"]
        print(sequence_to_classify)
        candidate_labels = ['viaje', 'cocina', 'danza']
        data = classifier(sequence_to_classify, candidate_labels)
        scores = data['scores']
        ind_score = scores.index(max(scores))
        clase = data['labels'][ind_score]
        json_file['query'] = clase
        print(json_file)
        return jsonify(json_file)
    else:
        return jsonify(json_file)


if __name__ == '__main__':
    app.run()
