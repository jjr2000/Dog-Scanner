import matplotlib.pyplot as plt
import tensorflow as tf
from tensorflow.keras.applications import * #Efficient Net included here
from tensorflow.keras import models, layers, preprocessing, optimizers, callbacks

#Use this to check if the GPU is configured correctly
from tensorflow.python.client import device_lib
from tensorflow.python.keras.layers.preprocessing.image_preprocessing import RandomRotation, RandomTranslation, RandomFlip, RandomContrast
print(device_lib.list_local_devices())
tf.device('/GPU:0')

batch_size = 32
img_size = 528
epochs = 100

checkpoint_path = "Training/cp.ckpt"
# Create a callback that saves the model's weights
cp_callback =callbacks.ModelCheckpoint(filepath=checkpoint_path,
                                                 save_weights_only=True,
                                                 verbose=1)

# Load dataset from file.
training_set = preprocessing.image_dataset_from_directory("Processed Dataset", label_mode="categorical", batch_size=batch_size, image_size=(img_size, img_size), seed=18683045, subset="training", validation_split=0.2)
validation_set = preprocessing.image_dataset_from_directory("Processed Dataset", label_mode="categorical", batch_size=batch_size, image_size=(img_size, img_size), seed=18683045, subset="validation", validation_split=0.2)

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
    layers.Dense(len(training_set.class_names), activation="softmax", name="Dense_layer")
])

conv_base.trainable = False

model.compile(
    loss="categorical_crossentropy",
    optimizer=optimizers.RMSprop(lr=2e-5),
    metrics=["accuracy"],
)

model.summary()

hist = model.fit(
    training_set,
    batch_size= batch_size,
    epochs=epochs,
    verbose=1,
    validation_data=validation_set,
    validation_steps=len(validation_set) // batch_size,
    workers=20,
    use_multiprocessing=True,
    callbacks=[cp_callback]
)

plt.plot(hist.history["accuracy"])
plt.plot(hist.history["val_accuracy"])
plt.title("model accuracy")
plt.ylabel("accuracy")
plt.xlabel("epoch")
plt.legend(["train", "validation"], loc="upper left")
plt.show()

loss, accuracy = model.evaluate(training_set)
print("Loss :", loss)
print("Accuracy :", accuracy)