import tensorflow as tf
import tensorflow_hub as hub
from PIL import Image
from flask import Flask, render_template
from flask_restful import Resource, Api, reqparse
import numpy as np
import base64
import io

physical_devices = tf.config.experimental.list_physical_devices('GPU')
assert len(physical_devices) > 0, "Not enough GPU hardware devices available"
config = tf.config.experimental.set_memory_growth(physical_devices[0], True)

app = Flask(__name__)
api = Api(app)

breeds = ['Afghan_hound', 'African_hunting_dog', 'Airedale', 'American_Staffordshire_terrier', 'Appenzeller', 'Australian_terrier', 'Bedlington_terrier', 'Bernese_mountain_dog', 'Blenheim_spaniel', 'Border_collie', 'Border_terrier', 'Boston_bull', 'Bouvier_des_Flandres', 'Brabancon_griffon', 'Brittany_spaniel', 'Cardigan', 'Chesapeake_Bay_retriever', 'Chihuahua', 'Dandie_Dinmont', 'Doberman', 'English_foxhound', 'English_setter', 'English_springer', 'EntleBucher', 'Eskimo_dog', 'French_bulldog', 'German_shepherd', 'German_short-haired_pointer', 'Gordon_setter', 'Great_Dane', 'Great_Pyrenees', 'Greater_Swiss_Mountain_dog', 'Ibizan_hound', 'Irish_setter', 'Irish_terrier', 'Irish_water_spaniel', 'Irish_wolfhound', 'Italian_greyhound', 'Japanese_spaniel', 'Kerry_blue_terrier', 'Labrador_retriever', 'Lakeland_terrier', 'Leonberg', 'Lhasa', 'Maltese_dog', 'Mexican_hairless', 'Newfoundland', 'Norfolk_terrier', 'Norwegian_elkhound', 'Norwich_terrier', 'Old_English_sheepdog', 'Pekinese', 'Pembroke', 'Pomeranian', 'Rhodesian_ridgeback', 'Rottweiler', 'Saint_Bernard', 'Saluki', 'Samoyed', 'Scotch_terrier', 'Scottish_deerhound', 'Sealyham_terrier', 'Shetland_sheepdog', 'Shih-Tzu', 'Siberian_husky', 'Staffordshire_bullterrier', 'Sussex_spaniel', 'Tibetan_mastiff', 'Tibetan_terrier', 'Walker_hound', 'Weimaraner', 'Welsh_springer_spaniel', 'West_Highland_white_terrier', 'Yorkshire_terrier', 'affenpinscher', 'basenji', 'basset', 'beagle', 'black-and-tan_coonhound', 'bloodhound', 'bluetick', 'borzoi', 'boxer', 'briard', 'bull_mastiff', 'cairn', 'chow', 'clumber', 'cocker_spaniel', 'collie', 'curly-coated_retriever', 'dhole', 'dingo', 'flat-coated_retriever', 'giant_schnauzer', 'golden_retriever', 'groenendael', 'keeshond', 'kelpie', 'komondor', 'kuvasz', 'malamute', 'malinois', 'miniature_pinscher', 'miniature_poodle', 'miniature_schnauzer', 'otterhound', 'papillon', 'pug', 'redbone', 'schipperke', 'silky_terrier', 'soft-coated_wheaten_terrier', 'standard_poodle', 'standard_schnauzer', 'toy_poodle', 'toy_terrier', 'vizsla', 'whippet', 'wire-haired_fox_terrier']

od_size = (1024, 1024)
# This model is trained on COCO 2017
object_detector = hub.load("https://tfhub.dev/tensorflow/efficientdet/d4/1")
dc_size = (528,528)
dog_classifier = tf.keras.models.load_model("models/dog_model")

def runDetection(image_file):
    im = image_file.resize(od_size)
    im_data = np.asarray(im)
    input_tensor = tf.convert_to_tensor(im_data)
    input_tensor = input_tensor[None,...]
    objects = object_detector(input_tensor)
    num = objects["num_detections"].numpy()[0]
    boxes = objects["detection_boxes"].numpy()[0]
    classes = objects["detection_classes"].numpy()[0]
    scores = objects["detection_scores"].numpy()[0]
    dog = []
    for i in range(int(num)):
        if int(classes[i]) == 18 and scores[i] >= 0.4:
            box = boxes[i]
            crp = image_file.crop([round(image_file.width * box[1]),round(image_file.height * box[0]),round(image_file.width * box[3]),round(image_file.height * box[2])])
            dog_im = crp.resize(dc_size)
            dog_im_data = np.asarray(dog_im)
            dog_im_tensor = tf.convert_to_tensor(dog_im_data)
            dog_im_tensor = dog_im_tensor[None,...]
            breed = dog_classifier(dog_im_tensor)
            breed = breed.numpy()[0]
            breedSort = np.sort(breed)
            dogBreeds = []
            for b in np.flip(breedSort):
                if b < 0.05:
                    break
                idx, = np.where(breed == b)
                dogBreeds.append({'breed':breeds[idx[0]], 'certainty':int(b*100)})

            if dogBreeds:
                img_byte_arr = io.BytesIO()
                crp.save(img_byte_arr, format='JPEG')
                img_byte_arr = img_byte_arr.getvalue()
                dog.append({'breeds':dogBreeds,'image':base64.b64encode(img_byte_arr).decode('utf-8')})

    return dog

@app.route('/')

class imageSend(Resource): #function call for the /imageSend/ url
    def post(self): #this is a post request
        parser = reqparse.RequestParser()
        parser.add_argument('image', type=str, required=True)
        args = parser.parse_args()
        img = args['image']
        binary = base64.b64decode(img)
        image = Image.open(io.BytesIO(binary))
        dog = runDetection(image)
        return {"dog" : dog} #URL safe base64 string is returned in JSON


api.add_resource(imageSend, '/imageSend')

if __name__ == '__main__':
    app.run(debug=True)
