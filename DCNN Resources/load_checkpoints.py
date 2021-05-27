import matplotlib.pyplot as plt
import tensorflow as tf
from tensorflow.keras.applications import * #Efficient Net included here
from tensorflow.keras import models, layers, preprocessing, optimizers, callbacks

#Use this to check if the GPU is configured correctly
from tensorflow.python.client import device_lib
from tensorflow.python.keras.layers.preprocessing.image_preprocessing import RandomRotation, RandomTranslation, RandomFlip, RandomContrast

checkpoint_path = "Training/cp.ckpt"

img_size = 528
# Options: EfficientNetB0, EfficientNetB1, EfficientNetB2, EfficientNetB3, ... up to  7
# Higher the number, the more complex the model is. and the larger resolutions it  can handle, but  the more GPU memory it will need
# loading pretrained conv base model
#input_shape is (height, width, number of channels) for images
conv_base = EfficientNetB6(weights="imagenet", include_top=False, input_shape=(img_size, img_size, 3))


model = models.Sequential([
    layers.Input(shape=(img_size, img_size, 3)),
    RandomRotation(factor=0.15),
    RandomTranslation(height_factor=0.1, width_factor=0.1),
    RandomFlip(),
    RandomContrast(factor=0.1),
    conv_base,
    layers.GlobalMaxPooling2D(name="GMP2D_layer"),
    layers.Dropout(rate=0.2, name="Dropout_layer"),
    layers.Dense(120, activation="softmax", name="Dense_layer")
])

conv_base.trainable = False

model.compile(
    loss="categorical_crossentropy",
    optimizer=optimizers.RMSprop(lr=2e-5),
    metrics=["accuracy"],
)

model.load_weights(checkpoint_path)
model.summary()

cleaned_model = models.Sequential([
    layers.Input(shape=(img_size, img_size, 3)),
    model.layers[4],
    model.layers[5],
    model.layers[6],
    model.layers[7]
])

cleaned_model.compile(
    loss="categorical_crossentropy",
    optimizer=optimizers.RMSprop(lr=2e-5),
    metrics=["accuracy"],
)
cleaned_model.summary()

cleaned_model.save('Saved_Model/dog_modelss')


