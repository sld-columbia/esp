import numpy as np
import os
import argparse
import scipy.io as sio
import h5py

MAT_PATH = './mat'
HDF5_PATH = './h5'

def load_mat_svhn_dataset(path):
    train_filename = path + '/train_32x32.mat'
    test_filename = path + '/test_32x32.mat'
    extra_filename = path + '/extra_32x32.mat'

    print('INFO: Loading:', train_filename)
    train_images = sio.loadmat(train_filename)
    print('INFO: Loading:', test_filename)
    test_images = sio.loadmat(test_filename)
    print('INFO: Loading:', extra_filename)
    extra_images = sio.loadmat(extra_filename)

    return train_images, test_images, extra_images

def get_images_labels(dataset):
    print('INFO: Get images and labels ...')
    imgs = dataset['X']
    imgs = np.transpose(imgs, (3, 0, 1, 2))

    labels = dataset['y']
    # replace label '10' with label '0'
    labels[labels == 10] = 0

    return imgs, labels

# TODO: We can normalize later on.
#def normalize_rgb_images(imgs):
#    print('INFO: Normalizing ...')
#    # normalize dataset so pixel values are in range [0,1]
#    scalar = 1 / 255.
#    norm_imgs = imgs * scalar
#    return norm_imgs

def rgb_to_gray(imgs):
    print('INFO: RGB to grayscale ...')
    gray_imgs = np.average(imgs, weights=[0.299, 0.587, 0.114], axis=3)
    return gray_imgs

def save_h5_dataset(X, y, name, path, X_dtype='float32', y_dtype='int32'):
    filename = path + '/' + name + '.h5'
    print('INFO: Saving:', filename)
    with h5py.File(filename, 'w') as f:
        f.create_dataset('X', data=X, shape=X.shape, dtype=X_dtype, compression='gzip')
        f.create_dataset('y', data=y, shape=y.shape, dtype=y_dtype, compression='gzip')

def main():
    train_dataset, test_dataset, extra_dataset = load_mat_svhn_dataset(MAT_PATH)

    rgb_train_images, train_labels = get_images_labels(train_dataset)
    gray_train_images = rgb_to_gray(rgb_train_images)
    save_h5_dataset(rgb_train_images, train_labels, 'svhn_rgb_train', HDF5_PATH, X_dtype='int32')
    save_h5_dataset(gray_train_images, train_labels, 'svhn_grayscale_train', HDF5_PATH)

    rgb_test_images, test_labels = get_images_labels(test_dataset)
    gray_test_images = rgb_to_gray(rgb_test_images)
    save_h5_dataset(rgb_test_images, test_labels, 'svhn_rgb_test', HDF5_PATH, X_dtype='int32')
    save_h5_dataset(gray_test_images, test_labels, 'svhn_grayscale_test', HDF5_PATH)

    rgb_extra_images, extra_labels = get_images_labels(extra_dataset)
    gray_extra_images = rgb_to_gray(rgb_extra_images)
    save_h5_dataset(rgb_extra_images, extra_labels, 'svhn_rgb_extra', HDF5_PATH, X_dtype='int32')
    save_h5_dataset(gray_extra_images, extra_labels, 'svhn_grayscale_extra', HDF5_PATH)

if __name__ == '__main__':
    main()
