from __future__ import print_function

import numpy as np
from matplotlib import pyplot as plt


def load_yuv_img_from_txt_YUV_ONLY(filename, n_rows = 256, n_cols = 256):
    with open(filename) as f:
        content = [int(line.rstrip('\n')) for line in open(filename)]
        return np.asarray(content).reshape((n_rows, n_cols))

def main():

    y_img = load_yuv_img_from_txt_YUV_ONLY('./undark/img_0.txt')
    plt.imshow(y_img, cmap=plt.cm.binary, vmin=0, vmax=255)
    plt.show()


if __name__ == '__main__':
    main()
