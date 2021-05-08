Cholesky datagen

The script gen.sh calls the python program datagen.py, which creates a random
matrix of user-specified size, performs the Cholesky decomposition, and then
saves the input and output matrices. The files input.txt and output.txt are used
by the SystemC testbench. The file data.h is used by both the baremetal and
linux applications. All files are referenced from this location, so nothing
needs to be copied to a different folder.
