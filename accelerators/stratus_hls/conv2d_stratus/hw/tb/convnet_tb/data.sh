#!/bin/bash

mkdir -p model
cd model
wget "https://espdev.cs.columbia.edu/stuff/esp/nn_apps/convnet_model_rv.tar.gz"
tar xzvf convnet_model_rv.tar.gz
rm convnet_model_rv.tar.gz
