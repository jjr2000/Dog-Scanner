import requests
import base64
from PIL import Image

image_file = open("test_images/leo.jpg", "rb").read()  
base64string = base64.b64encode(image_file)
url = f'http://127.0.0.1:5000/imageSend'

payload = {'image':base64string}
headers= {}

response = requests.request("POST", url, headers=headers, data=payload)

print(response.text)
