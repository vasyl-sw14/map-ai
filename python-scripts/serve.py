import logging, requests, os, io, glob, time
import json
import base64

import torch

from fastai.text import *
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

JSON_CONTENT_TYPE = 'application/json'
    

def model_fn(model_dir):
    logger.info('model_fn')
    path = Path(model_dir)
    learn = load_learner(model_dir, 'fastai_model_resnet50.pkl')
    return learn


def predict_fn(input, model):
    logger.info("Calling model")
    start_time = time.time()
    img = base64.b64decode(input)
    result, _, __ = model.predict(img)
    print("--- Inference time: %s seconds ---" % (time.time() - start_time))
    return json.dumps({
        "input": input,
        "result": result
    })

def input_fn(request_body, content_type=JSON_CONTENT_TYPE):
    logger.info('Deserializing the input data.')
    if content_type == JSON_CONTENT_TYPE: return request_body["img"]   
    raise Exception('Requested unsupported ContentType in content_type: {}'.format(content_type))
    
def output_fn(prediction, accept=JSON_CONTENT_TYPE):        
    logger.info('Serializing the generated output.')
    if accept == JSON_CONTENT_TYPE: return json.dumps(prediction), accept
    raise Exception('Requested unsupported ContentType in Accept: {}'.format(accept))