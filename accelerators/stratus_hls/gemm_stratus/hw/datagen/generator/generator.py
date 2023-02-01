#!/bin/python

# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

import sys
import random

def gen(is_transposed, batch_size, rowsA, colsA, colsB, name):

    # define range of random matrix elements values
    value_range = 5

    matrixA = open("../input/" + name + "_A.txt", 'w')
    barec_in = open("../input/" + name + "_barec_in.h", 'w')
    barec_i = 0

    matrixA.write("3 ")           # dim
    matrixA.write("0 ")  # is_transposed
    matrixA.write(str(batch_size) + " ")  # batch_size
    matrixA.write(str(rowsA) + " ")  # rowsA
    matrixA.write(str(colsA) + "\n") # colsA

    for i in range(0, batch_size * rowsA * colsA):
        val = random.randint(-value_range, value_range)
        matrixA.write(str(val) + " ")
        barec_in.write("in[" + str(barec_i) + "] = " + str(val) + ";\n")
        barec_i += 1

    matrixA.close()

    matrixB = open("../input/" + name + "_B.txt", 'w')

    matrixB.write("3 ")           # dim
    matrixB.write(str(is_transposed) + " ")  # is_transposed
    matrixB.write(str(batch_size) + " ")  # batch_size
    matrixB.write(str(colsA) + " ")  # colsA
    matrixB.write(str(colsB) + "\n") # colsB

    for i in range(0, batch_size * colsA * colsB):
        val = random.randint(-value_range, value_range)
        matrixB.write(str(val) + " ")
        barec_in.write("in[" + str(barec_i) + "] = " + str(val) + ";\n")
        barec_i += 1

    matrixB.close()

def main():

    # Generate small sized matrices
    gen(1,
        random.randint(2, 2),
        random.randint(4, 4) * 2,
        random.randint(4, 4) * 2,
        random.randint(4, 4) * 2,
        "testS")

    # Generate medium sized matrices
    gen(1,
        random.randint( 1, 1),
        random.randint(32, 32) * 2,
        random.randint(32, 32) * 2,
        random.randint(32, 32) * 2,
        "testM")

    # Generate large sized matrices
    gen(1,
        random.randint( 1,   1),
        random.randint(128, 128) * 2,
        random.randint(128, 128) * 2,
        random.randint(128, 128) * 2,
        "testL")

    # Generate matrices with single row matrix A and single column matrix B
    gen(1,
        random.randint(1, 1),
        1,
        random.randint(2048, 2048) * 2,
        1,
        "testR")

    # Generate matrices with single column matrix A and single row matrix B
    gen(1,
        random.randint(1, 1),
        random.randint(64,64) * 2,
        1,
        random.randint(64,64) * 2,
        "testC")

    # Generate matrices with non-transposed matrix B
    gen(0,
        random.randint(1, 1),
        random.randint(4, 4) * 2,
        random.randint(4, 4) * 2,
        random.randint(4, 4) * 2,
        "testNTS")

    # Generate matrices with non-transposed matrix B
    gen(0,
        random.randint(1, 1),
        random.randint(32, 32) * 2,
        random.randint(32, 32) * 2,
        random.randint(32, 32) * 2,
        "testNTM")

    # Generate matrices with non-transposed matrix B
    gen(0,
        random.randint(1, 1),
        random.randint(128, 128) * 2,
        random.randint(128, 128) * 2,
        random.randint(128, 128) * 2,
        "testNTL")

    print("Info: input successfully generated")

if __name__ == "__main__":
    main()
