#!/usr/bin/env python

import sys
import numpy as np
from scipy import misc

def main(argv):

    if len(argv) != 3:
        print("Usage: ./txt_to_image [.txt] [.jpg]")
        return 1

    txt = open(str(argv[1]), "r")

    txt_ = txt.read().replace("\n", " ")
    txt_ = " ".join(txt_.split())
    lst = map(float, txt_.split(" "))

    num_rows = int(lst[0])
    num_cols = int(lst[1])

    print np.array(lst[2:])

    img = misc.toimage(np.array(lst[2:]).reshape(
        num_rows, num_cols), mode = 'F')

    misc.imsave(str(argv[2]), img)

    return 0

if __name__ == "__main__":
    main(sys.argv)

