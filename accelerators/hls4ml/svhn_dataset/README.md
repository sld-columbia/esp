# The Street View House Numbers (SVHN) Dataset

SVHN is a real-world image dataset of house numbers collected from the Google Street View images. It is similar in flavor to MNIST (i.e. images of small cropped digits), but the dataset is 10x bigger and recognizing digits and numbers in natural scene images is a significantly harder problem.

More information are available at the [Official SVHN webpage](http://ufldl.stanford.edu/housenumbers).

## Quick Start

### Download

Download the cropped-digit dataset in `.mat` format (_Format 2_):
```
make download
```

The files are in the directory `mat` and their sizes are:
- `mat/train_32x32.mat` 174MB
- `mat/test_32x32.mat` 62MB
- `mat/extra_32x32.mat` 1.3GB

### Preprocess Datasets

In Python/Tensorflow/Keras, it is more convenient to use the [HDF5 library and file format](https://www.hdfgroup.org/solutions/hdf5). Preprocess, convert to grayscale, and save the dataset as HDF5 files:
```
make preprocess
```

This step generates two ML datasets: RGB and grayscale images. The first set has three color channels and can (but not necessarely) be used with CNN; while the second set has a single channel, i.e. it is smaller, and was designed to be used with MLP. The files are in the directory `h5`.

The sizes of the RGB-image files are:
- `h5/svhn_rgb_extra.h5` 2.1GB
- `h5/svhn_rgb_test.h5` 101MB
- `h5/svhn_rgb_train.h5` 293MB

The sizes of the grayscale-image files are:
- `h5/svhn_gray_extra.h5` 1.8GB
- `h5/svhn_gray_test.h5` 87MB
- `h5/svhn_gray_train.h5` 248MB

### Resize Images

```
make resize-32
make resize-256
```

The output is in `bmp`.

### Show Images
```
make show
```

### Dark Images

```
make dark-256
```

The output is in `txt`.
