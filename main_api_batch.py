import config
import cv2
from flask import Flask, Response, request, redirect, jsonify
import requests
from werkzeug.utils import secure_filename
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
import numpy as np
import json
import os
from tools import test_net_batch

app = Flask(__name__)

class NumpyEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, np.ndarray):
            return obj.tolist()
        return json.JSONEncoder.default(self, obj)

os.makedirs(config.UPLOAD_IMAGE_FOLDER, exist_ok=True)
ALLOWED_EXTENSIONS = set(['png', 'jpg', 'jpeg'])

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/infer', methods=['POST'])
def upload():
    # check if the post request has the file part
    
    if 'files' not in request.files:
        resp = jsonify({'message' : 'No file part in the request'})
        resp.status_code = 400
        return resp
    
    files = request.files.getlist('files')
    
    errors = {}
    success = False
    
    for file in files:      
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file.save(os.path.join(config.UPLOAD_IMAGE_FOLDER, filename))
            success = True
        else:
            errors[file.filename] = 'File type is not allowed'
    import time
    start = time.time()
    response = main()
    print(time.time() - start)

    if success and errors:
        errors['message'] = 'File(s) successfully uploaded'
        resp = jsonify(errors)
        resp.status_code = 500
        return resp
    if success:
        resp = response
        return resp
    else:
        resp = jsonify(errors)
        resp.status_code = 500
        return resp


# route http posts to this method
def main():
    files = [os.path.join(config.UPLOAD_IMAGE_FOLDER, file) for file in os.listdir(config.UPLOAD_IMAGE_FOLDER)]
    with open(config.TEST_LIST_PATH, 'w') as fw:
        for file in files:
            fw.write(os.path.basename(file) + '\n')
    test_net_batch.main_inference()
    result = []
    for file in files:
        filename = os.path.basename(file).split('.')[0]
        with open(os.path.join(config.INFERENCE_RESULT, 'res_'+filename+'.txt'), 'r') as fr:
            result.append(fr.readlines())
    response = json.dumps(result, cls=NumpyEncoder)
    [os.remove(file) for file in files]

    if os.path.exists(os.path.join(config.UPLOAD_FOLDER, 'test_list.txt')):
        os.remove(os.path.join(config.UPLOAD_FOLDER, 'test_list.txt'))
    # Uncomment this code for CPU inference
    # [os.remove(os.path.join(config.INFERENCE_RESULT, f)) for f in os.listdir(config.INFERENCE_RESULT)]
    # [os.remove(os.path.join(config.INFERENCE_VISU, f)) for f in os.listdir(config.INFERENCE_VISU)]

    return Response(response=response, status=200, mimetype="application/json")

if __name__ == '__main__':
    if config.SERVER_TYPE == 'wsgi':
        from gevent.pywsgi import WSGIServer
        WSGIServer((config.IP, config.PORT), app).serve_forever()
    elif config.SERVER_TYPE == 'flask':
        app.run(config.IP, config.PORT, debug=True, threaded=True)
    else:
        raise Exception('server type not found')
