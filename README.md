# Dog Scanner
<img alt="Image of Dog Scanner Logo" src="https://raw.githubusercontent.com/jjr2000/Dog-Scanner/main/Logo.svg" width="300">
Whether you have a doggo, pupper, woofer or floofer, every hooman endevours to know the breed of their furry friend! Dog Scanner aims to answer this question. Using cutting edge computer vision, machine learning and neural network technology, Dog Scanner will make a best guess estimate of what breed (or mix of breeds) your doggo is.

## Compiling and running each segment of the code

All the code that is involved in processing the data set, training the model and exporting it is within the DCNN Resources directory.

### DCNN Resources directory
#### Dog Extractor
Dog Extractor is the program that has been written to process the Stanford Dogs dataset ready from teh model to train off, The datasets images and annotations can be downloaded and extracted into there respective folders within Original Dataset from: http://vision.stanford.edu/aditya86/ImageNetDogs/

This Soloution was written in Visual Studio 2019 with C++ tools, though other versions of Visual studio may also work.

The program relies on Boost and OpenCV which can be installed using vcpkg.
Instruction on the instalation and use of vcpkg can be found here: https://github.com/microsoft/vcpkg#quick-start-windows

Main.cpp is then simply run in the solution and the data set will be processed.

#### Python Setup
Several programs to follow where written in Python, more specifically version 3.8.6 which can be downloaded from here: https://www.python.org/downloads/release/python-386/

The versions of the following packages can then be installed using PIP

Package | Version
--------|--------
matplotlib | 3.3.3
tensorflow | 2.4.0
tensorflow-hub | 0.12.0
Pillow | 8.0.1
numpy | 1.19.3
Flask | 1.1.4
FlaskRESTful | 0.3.9 

If an NVIDIA GPU is installed in your system, the CUDA toolkit also needs to be installed to take full advantage of it, this can be downloaded from here: https://developer.nvidia.com/cuda-downloads

#### train_model.py

train_model.py can simply be run from IDLE and will start training as long as the processed data is in place.

#### load_checkpoints.py

After train_model.py has been run load_checkpoints.py can then be run in IDLE and it will load the trained checkpoints, clean the network structure then export a completed model which can be copied into the Web API's model photo.

### Web_API directory
#### check_acc.py
Once a trained model has been put in the models directory, check_acc.py can be run in IDLE to evaluate it's mean accuracy on the entire original dataset.

#### app.py
app.py is a flask app so needs to be run slighly diffrentley to the other python scripts, in a command window the Web_API directory must be CD'd into then the following command needs to be run
> flask run –host=0.0.0.0

With -host=0.0.0.0 making accessible from all netowrk interfaces on a machine.
Next a firewall rule must be set up to allow tcp requests on port 5000
Finally if ecternal accessibility is required a port forwarding rule must be set up in your router.

#### tester.py
Once the flask service is running, tester.py can be run in IDLE to check it is working.

### src directory
The source directory contains the Flutter application, to build, compile and run this you firslty need installed Flutter and Android Studio, the full instructions for this can be found here: https://flutter.dev/docs/get-started/install/windows

The src directory can then be opened with android studio. Once open the packages get command must be run to install the apps dependancies.
To be able to build the app a unique signig key will need to set up following this guide here: https://flutter.dev/docs/deployment/android

Finally the address on Line 5 of lib/detect_breed.dart must be updated to that of your machine IP address, or external if port forwarding has been setup.

The app can be be built and run on your device of choice.

# Credit

This repository is the sole creation of Jaidon James Rymer.

Produced as part of his final year project.

Submitted in partial fulfilment of the requirements for the Degree of BSc(Hons) Computer Science at School of Computer Science, College of Science, University of Lincoln
