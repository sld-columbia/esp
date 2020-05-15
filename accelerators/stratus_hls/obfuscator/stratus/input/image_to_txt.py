#!/usr/bin/env python

import sys
from scipy import misc

def main(argv):

    if len(argv) != 2:
        print("Usage: ./image_to_txt [.jpg]")
        return 1

    img = misc.imread(str(argv[1]), 'F')

    num_rows = int(img.shape[0])
    num_cols = int(img.shape[1])

    print num_rows, num_cols
    for x in range(num_rows):
        for y in range(num_cols):
            print img[x][y],
        print ""

    return 0

if __name__ == "__main__":
    main(sys.argv)

