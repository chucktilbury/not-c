################################################################################
#
#	Makefile for nop
#
################################################################################
PLATNAME := $(shell uname)

all:
	make -C src

clean:
	make -C src clean
	make -C tests clean

allclean:
	make -C src allclean

pretty:
	make -C src pretty

test:
	make -C tests
