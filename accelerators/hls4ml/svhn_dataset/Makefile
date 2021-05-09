help:
	@echo "INFO: make <TAB> to show the options"
.PHONY:

download: mat/train_32x32.mat mat/test_32x32.mat mat/extra_32x32.mat
.PHONY: download

mat/train_32x32.mat:
	wget -P mat http://ufldl.stanford.edu/housenumbers/train_32x32.mat

mat/test_32x32.mat:
	wget -P mat http://ufldl.stanford.edu/housenumbers/test_32x32.mat

mat/extra_32x32.mat:
	wget -P mat http://ufldl.stanford.edu/housenumbers/extra_32x32.mat

preprocess:
	python ./preprocess.py
.PHONY: preprocess

resize-32:
	python ./resize.py 32
.PHONY: resize-32

resize-256:
	python ./resize.py 256
.PHONY: resize-256

dark-256:
	python ./dark.py 256
.PHONY: dark-256

dark-128:
	python ./dark.py 128
.PHONY: dark-128

dark-64:
	python ./dark.py 64
.PHONY: dark-64

dark-32:
	python ./dark.py 32
.PHONY: dark-32


show:
	python ./show.py
.PHONY: show

clean:
	rm -rf mat
.PHONY: clean

ultraclean: clean
	rm -rf h5
.PHONY: ultraclean
