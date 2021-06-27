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

all_clean:
	make-C src all_clean

pretty:
	make -C src pretty

test:
	make -C tests
