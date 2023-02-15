#!/bin/python
# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
import numpy as np
n = input("Enter Number of Rows in the Matrix : ")
K = np.random.randint(5, size=(n, n))
A = np.random.rand(n, n)
B=A.transpose()
C = np.dot(A, B)
D= np.identity(n)
E= n*D
F = np.add(C,E)
np.savetxt('input.txt',F,fmt='%.6f')
L = np.linalg.cholesky(F)
np.savetxt('output.txt',L,fmt='%.8f')
out = open("data.h", "w")
for i in range(0,n):
  for j in range(0,n):
	index = i*n+j
	out.write("buf[" + str(index) + "] = float2fx((float) " + str(F[i][j]) + ", FX_IL);\n")

for i in range(0,n):
  for j in range(0,n):
	index = i*n+j
	out.write("gold[" + str(index) + "] = float2fx((float) " + str(L[i][j]) + ", FX_IL);\n")
out.close()
