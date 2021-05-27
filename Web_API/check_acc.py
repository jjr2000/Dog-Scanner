import tensorflow as tf
from tensorflow.keras.applications import * #Efficient Net included here
from tensorflow.keras import models, layers, preprocessing, optimizers, callbacks

batch_size = 32
img_size = 528

physical_devices = tf.config.experimental.list_physical_devices('GPU')
assert len(physical_devices) > 0, "Not enough GPU hardware devices available"
config = tf.config.experimental.set_memory_growth(physical_devices[0], True)
full_set = preprocessing.image_dataset_from_directory("..\DCNN Resources\Processed Dataset", label_mode="categorical", batch_size=batch_size, image_size=(img_size, img_size))

dog_classifier = tf.keras.models.load_model("models/dog_model")

loss, accuracy = dog_classifier.evaluate(full_set)
print("Loss :", loss)
print("Accuracy :", accuracy)