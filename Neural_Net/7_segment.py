import tensorflow as tf
from tensorflow.keras import layers
import numpy as np

# Load the dataset
(x_train, y_train), (x_test, y_test) = tf.keras.datasets.mnist.load_data()

# Preprocess the data
x_train = x_train.reshape(-1, 28, 28, 1).astype("float32") / 255.0
x_test = x_test.reshape(-1, 28, 28, 1).astype("float32") / 255.0

# Define the model architecture
model = tf.keras.Sequential([
    layers.Conv2D(32, (3, 3), activation="relu", input_shape=(28, 28, 1)),
    layers.MaxPooling2D((2, 2)),
    layers.Flatten(),
    layers.Dense(128, activation="relu"),
    layers.Dense(10, activation="softmax")
])

# Compile the model
model.compile(optimizer="adam", loss="sparse_categorical_crossentropy", metrics=["accuracy"])

# Train the model
model.fit(x_train, y_train, batch_size=128, epochs=5, validation_data=(x_test, y_test))

# Save the model
model.save("digit_recognition_model")

# Load the model
model = tf.keras.models.load_model("digit_recognition_model")

# Function to preprocess a single image
def preprocess_image(image):
    image = image.reshape(-1, 28, 28, 1).astype("float32") / 255.0
    return image

# Function to predict the digit
def predict_digit(image):
    preprocessed_image = preprocess_image(image)
    predictions = model.predict(preprocessed_image)
    digit = np.argmax(predictions[0])
    return digit

# Example usage
image = ...  # Load or capture an image of a digit from the 7-segment display
predicted_digit = predict_digit(image)
print("Predicted digit:", predicted_digit)

