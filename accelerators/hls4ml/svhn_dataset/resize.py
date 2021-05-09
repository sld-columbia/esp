import cv2
import sys
import h5py
import numpy as np
import scipy.io as sio
from matplotlib import pyplot as plt

HDF5_PATH = './h5'
MAT_PATH = './mat'

if (len(sys.argv) == 2):
    SIZE = int(sys.argv[1])
else:
    raise ValueError('ERROR: Usage: python ' + str(sys.argv[0]) + ' <SIZE>')

def load_h5_svhn_dataset(path):
    train_filename = path + '/svhn_rgb_train.h5'
    test_filename = path + '/svhn_rgb_test.h5'
    extra_filename = path + '/svhn_rgb_extra.h5'

    print('INFO: Loading:', train_filename)

    X_train = h5py.File(train_filename, 'r')['X']
    y_train = h5py.File(train_filename, 'r')['y']

    print('INFO: Loading:', test_filename)

    X_test = h5py.File(test_filename, 'r')['X']
    y_test = h5py.File(test_filename, 'r')['y']

    print('INFO: Loading:', extra_filename)

    X_extra = h5py.File(extra_filename, 'r')['X']
    y_extra = h5py.File(extra_filename, 'r')['y']

    return X_train, y_train, X_test, y_test, X_extra, y_extra

def load_mat_svnh_dataset(path):
    train_filename = path + '/train_32x32.mat'
    test_filename = path + '/test_32x32.mat'
    extra_filename = path + '/extra_32x32.mat'

    print('INFO: Loading:', train_filename)
    train_images = sio.loadmat(train_filename)
    print('INFO: Loading:', test_filename)
    test_images = sio.loadmat(test_filename)
    print('INFO: Loading:', extra_filename)
    extra_images = sio.loadmat(extra_filename)

    X_train = train_images['X']
    X_train = np.transpose(X_train, (3, 0, 1, 2))
    y_train = train_images['y']
    # replace label '10' with label '0'
    y_train[y_train == 10] = 0

    X_test = test_images['X']
    X_test = np.transpose(X_test, (3, 0, 1, 2))
    y_test = test_images['y']
    # replace label '10' with label '0'
    y_test[y_test == 10] = 0

    X_extra = extra_images['X']
    X_extra = np.transpose(X_extra, (3, 0, 1, 2))
    y_extra = extra_images['y']
    # replace label '10' with label '0'
    y_extra[y_extra == 10] = 0

    return X_train, y_train, X_test, y_test, X_extra, y_extra

def resize_and_save_bmp(X, y, nrows, ncols, path, dataset):
    for i in range(X.shape[0]):
        img = cv2.resize(X[i], (nrows, ncols), interpolation=cv2.INTER_CUBIC)
        label = int(y[i])
        img_path = path + '/'+ dataset + '_' + str(i) + '_' + str(nrows) + 'x' + str(ncols) + '_l' + str(label) + '.bmp'
        status = cv2.imwrite(img_path, img)
        print('INFO: Image resized (', nrows, 'x', ncols, ') and saved:', img_path, '(', status, ')')

def main():
    #X_train, y_train, X_test, y_test, X_extra, y_extra = load_h5_svhn_dataset(HDF5_PATH)
    X_train, y_train, X_test, y_test, X_extra, y_extra = load_mat_svnh_dataset(MAT_PATH)

    resize_and_save_bmp(X_test, y_test, SIZE, SIZE, 'bmp', 'test')

if __name__ == '__main__':
    main()
