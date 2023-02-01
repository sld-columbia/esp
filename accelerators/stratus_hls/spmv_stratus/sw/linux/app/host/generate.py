#!/usr/bin/env python
# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

# Generate a sparse matrices and a dense vector.
# Write them in files.

# Imports

import sys
import random
import numpy as np

# # Acquire command line parameters

# m_file       = sys.argv[1]
# n_rows       = int(sys.argv[2])
# n_cols       = int(sys.argv[3])
# max_val      = int(sys.argv[4])
# max_non_null = int(sys.argv[5])

# Matrix parameters for generation

n_mtx = 4
mtx_m_file = [['inputs/in1.mtx'  , 'inputs/in2.mtx',   \
               'inputs/in3.mtx'  , 'inputs/in4.mtx'],  \
              ['inputs/in_d1.mtx', 'inputs/in_d2.mtx', \
               'inputs/in_d3.mtx', 'inputs/in_d4.mtx'],\
              ['inputs/in_t1.mtx', 'inputs/in_t2.mtx', \
               'inputs/in_t3.mtx', 'inputs/in_t4.mtx']]

mtx_data_file = [['inputs/in1.data'  , 'inputs/in2.data',   \
                  'inputs/in3.data'  , 'inputs/in4.data'],  \
                 ['inputs/in_d1.data', 'inputs/in_d2.data', \
                  'inputs/in_d3.data', 'inputs/in_d4.data'],\
                 ['inputs/in_t1.data', 'inputs/in_t2.data', \
                  'inputs/in_t3.data', 'inputs/in_t4.data']]

mtx_chk_file = [['outputs/chk1.data'  , 'outputs/chk2.data',   \
                 'outputs/chk3.data'  , 'outputs/chk4.data'],  \
                ['outputs/chk_d1.data', 'outputs/chk_d2.data', \
                 'outputs/chk_d3.data', 'outputs/chk_d4.data'],\
                ['outputs/chk_t1.data', 'outputs/chk_t2.data', \
                 'outputs/chk_t3.data', 'outputs/chk_t4.data']]

mtx_n_rows = [512, 2048, 8192, 65536]
mtx_n_cols = [512, 2048, 8192, 65536]
mtx_max_val = 15
mtx_max_non_null = [8, 16, 16, 32]
mtx_diag_thickness = [10, 16, 32, 64]
mtx_n_types = 3

# Write list of matrices to create

for t in range(0, mtx_n_types):
  for m in range(0, n_mtx):

    # Acquire parameters defined locally

    m_file       = mtx_m_file[t][m]
    data_file    = mtx_data_file[t][m]
    chk_file     = mtx_chk_file[t][m]
    n_rows       = int(mtx_n_rows[m])
    n_cols       = int(mtx_n_cols[m])
    max_val      = int(mtx_max_val)
    max_non_null = int(mtx_max_non_null[m])
    diag_thickness = int(mtx_diag_thickness[m])

    # Generate matrix

    random.seed(23, version = 2)

    all_rows = []
    all_cols = []
    all_idxs = []
    all_vals = []
    all_vect = []
    all_chks = []
    idx = 0

    for r in range(0, n_rows):

      # index of all_vals where this row starts
      all_idxs.append(idx)

      # random number of non-null elements for the current row
      n_vals = random.randint(1, max_non_null)

      # columns to be associated to the random values
      if t == 0:
        cols = random.sample(range(0, n_cols - 1), n_vals)

      elif t == 1:
        left_c = max(0, r - diag_thickness)
        right_c = min(n_cols - 1, r + diag_thickness)

        cols = random.sample(range(left_c, right_c), n_vals)

      else:
        if r == 0:
          n_vals = 1
        elif r < max_non_null:
          n_vals = random.randint(1, r)

        cols = random.sample(range(0, r + 1), n_vals)

      cols.sort()

      # random float values of matrix elements
      vals = []
      for i in range(0, n_vals):
        vals.append(random.uniform(-max_val, max_val))
        idx += 1

      # append the info of the current row
      all_rows.extend(r * np.ones((n_vals,), dtype=np.int)) 
      all_cols.extend(cols)
      all_vals.extend(vals)

      # print(all_rows)
      # print(all_cols)
      # print(all_vals)

    all_idxs.append(idx)

    for c in range(0, n_cols):

      all_vect.append(random.uniform(-max_val, max_val))

    # Write matrix to file
    fp = open(m_file, "w+")

    input_size = 4 * (n_rows + len(all_cols)) + 8 * (n_cols + len(all_vals))

    fp.write("%% Rectangular sparse real valued matrix: row col value.\n")
    fp.write("%d %d %d %d\n" % (n_rows, n_cols, max_non_null, len(all_vals)))

    for i in range(0, len(all_rows)):

      fp.write("{0:d} {1:d} {2:2.13e}\n".format(all_rows[i], all_cols[i], all_vals[i]))

    fp.close()

    # Write input data for spmv

    fp = open(data_file, "w+")

    fp.write("%d %d %d %d\n" % (n_rows, n_cols, max_non_null, len(all_vals)))

    # Write array of sparse matrix values

    fp.write("%%\n")

    for i in range(0, len(all_vals)):

      fp.write("{0:.12g}\n".format(all_vals[i]))

    # Write columns corresponding to values

    fp.write("%%\n")

    for i in range(0, len(all_cols)):

      fp.write("{0:d}\n".format(all_cols[i]))

    # Write indexes of list of values where each row starts

    fp.write("%%\n")

    for i in range(0, len(all_idxs)):

      fp.write("{0:d}\n".format(all_idxs[i]))

    # Write vector values

    fp.write("%%\n")

    for i in range(0, len(all_vect)):

      fp.write("{0:.12g}\n".format(all_vect[i]))

    fp.close()

    # Write check file

    fp = open(chk_file, "w+")

    fp.write("%%\n")

    for i in range(0, n_rows):

      accum = 0
      si = 0

      begin = all_idxs[i]
      end = all_idxs[i + 1]

      for j in range(begin, end):

        si = all_vals[j] * all_vect[all_cols[j]]

        accum += si

      all_chks.append(accum)

      fp.write("{0:.12g}\n".format(accum))

    fp.close()
