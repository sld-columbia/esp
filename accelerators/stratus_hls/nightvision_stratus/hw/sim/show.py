# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
from __future__ import print_function

import numpy as np
from matplotlib import pyplot as plt


def load_yuv_img_from_txt_YUV_ONLY(filename, n_rows = 32, n_cols = 32):
    with open(filename) as f:
        content = [int(line.rstrip('\n')) for line in open(filename)]
        return np.asarray(content).reshape((n_rows, n_cols))

def main():

    # Set the parameters below corresponding to the txt image to be visualized

    size = 32

    y_img = load_yuv_img_from_txt_YUV_ONLY('./svhn_0_32x32.txt', size, size)
    plt.imshow(y_img, cmap=plt.cm.binary, vmin=0, vmax=256)
    plt.show()

    y_img = load_yuv_img_from_txt_YUV_ONLY('./svhn_0_gold_32x32.txt', size, size)
    plt.imshow(y_img, cmap=plt.cm.binary, vmin=0, vmax=256)
    plt.show()

    y_img = load_yuv_img_from_txt_YUV_ONLY('./svhn_0_out_32x32.txt', size, size)
    plt.imshow(y_img, cmap=plt.cm.binary, vmin=0, vmax=256)
    plt.show()

if __name__ == '__main__':
    main()
