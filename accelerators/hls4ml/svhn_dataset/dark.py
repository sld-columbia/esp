from __future__ import print_function
import sys
import keras
import scipy.io as sio
import numpy as np
import tensorflow as tf
from keras.datasets import cifar10
from matplotlib import pyplot as plt

from skimage.color import rgb2yuv
from skimage.transform import resize

def show_imgs(X, y):
    n_rows = 4
    n_cols = 4
    top_img = plt.figure()
    for i in range(0, n_rows * n_cols):
        img = top_img.add_subplot(n_rows, n_cols, i+1)
        img.set_title(str(get_cifar10_label(int(y[i]))))
        img.imshow(X[i])

    # show the plot
    plt.suptitle('SVHN')
    plt.show()

def show_yuv_imgs_Y_ONLY(imgs, labels):
    n_rows = 4
    n_cols = 4
    top_img = plt.figure()
    for i in range(0, n_rows * n_cols):
        img = top_img.add_subplot(n_rows, n_cols, i+1)
        img.set_title(str(int(labels[i])))
        y_img = imgs[i,:,:,0]
        img.imshow(y_img, cmap=plt.cm.binary, vmin = 0, vmax=255)

    # show the plot
    plt.suptitle('SVHN')
    plt.show()

def shift_value(value, orig_range = [0, 255], target_range = [0, 255]):
    return int(target_range[0] + ((target_range[1] - target_range[0]) / (orig_range[1] - orig_range[0])) * value)

def darkening(img):
    target_range = [0, 16]
    dark_img = img
    for h in range(img.shape[0]):
        for k in range(img.shape[1]):
            for c in range(img.shape[2]):
                dark_img[h][k][c] = shift_value(img[h][k][c], target_range = target_range)
    return dark_img

def darkening_YUV(img):
    target_range = [200, 255]
    dark_img = img
    for h in range(img.shape[0]):
        for k in range(img.shape[1]):
            for c in range(img.shape[2]):
                dark_img[h][k][c] = shift_value(img[h][k][c], target_range = target_range)
    return dark_img

def save_img_to_txt(img, id, directory = '.'):
    filename = directory +'/img_' + str(id) + '.txt'
    print('INFO: saving:', filename)
    img_file = open(filename, 'w+')
    img_file.write(str(img.shape[0]) + ' ' + str(img.shape[1]) + ' ' + str(img.shape[2]) + '\n')
    for h in range(img.shape[0]):
        for k in range(img.shape[1]):
            for c in range(img.shape[2]):
                img_file.write(str(img[h][k][c]) + ' ')
    img_file.close()

def save_yuv_img_to_txt_Y_ONLY(img, id, directory = '.'):
    filename = directory +'/img_' + str(id) + '.txt'
    print('INFO: saving:', filename)
    img_file = open(filename, 'w+')
    y_img = img[:,:,0]
    for h in range(y_img.shape[0]):
        for k in range(y_img.shape[1]):
            img_file.write(str(y_img[h][k]) + '\n')
    img_file.close()

def rgb_to_yuv_conversion(rgb_img):
    return rgb2yuv(rgb_img)
    #return cv2.cvtColor(rgb_img, cv2.COLOR_BGR2YUV)

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


HDF5_PATH = './h5'
MAT_PATH = './mat'

if (len(sys.argv) == 2):
    SIZE = int(sys.argv[1])
else:
    raise ValueError('ERROR: Usage: python ' + str(sys.argv[0]) + ' <SIZE>')

def main():
    # Load either BMP or MAT files.
    #X_train, y_train, X_test, y_test, X_extra, y_extra = load_h5_svhn_dataset(HDF5_PATH)
    X_train, y_train, X_test, y_test, X_extra, y_extra = load_mat_svnh_dataset(MAT_PATH)

    # At the moment we are interested in the test dataset only.
    X_test_size = X_test.shape[0]
    print('INFO:', 'SVHN test images:', X_test_size)

    # Resize and convert RGB to YUV format.
    yuv_X_test = np.array([], int).reshape(0, SIZE, SIZE, 3)
    for i in range(0, 16):#X_test_size):
        print('INFO: RGB to YUV:', i)
        bmp_img = resize(X_test[i], (SIZE, SIZE), anti_aliasing=True, preserve_range=True)
        yuv_img = rgb_to_yuv_conversion(bmp_img).astype(np.int32)
        yuv_X_test = np.append(yuv_X_test, [yuv_img], axis = 0)

    # Save SVHN in YUV format (only Y channel) to .TXT files.
    for i in range(0, 16):
        save_yuv_img_to_txt_Y_ONLY(yuv_X_test[i], str(i), directory = 'txt/yuv_Y_ONLY_' + str(SIZE) + 'x' + str(SIZE))

    # Show some images in YUV format (only Y channel).
    show_yuv_imgs_Y_ONLY(yuv_X_test, y_test)

    # Apply darkening filter to the images in YUV format.
    dark_yuv_X_test = np.array([], int).reshape(0, SIZE, SIZE, 3)
    for i in range(0, 16): #X_test_size):
        print('INFO: darkening:', i)
        dark_img = darkening_YUV(yuv_X_test[i])
        dark_yuv_X_test = np.append(dark_yuv_X_test, [dark_img], axis = 0)

    # Save SVHN in YUV format (only Y channel) to .TXT files after darkening.
    for i in range(0, 16):
        save_yuv_img_to_txt_Y_ONLY(dark_yuv_X_test[i], str(i), directory = 'txt/dark_yuv_Y_ONLY_' + str(SIZE) + 'x' + str(SIZE))

    # Show some images in YUV format after darkening (only Y channel).
    show_yuv_imgs_Y_ONLY(dark_yuv_X_test, y_test)

if __name__ == '__main__':
    main()
