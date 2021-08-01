################################################################################
#
#	Makefile for nop
#
################################################################################
PLATNAME := $(shell uname)

all:
	make -C src

remake:
	make -C src remake

clean:
	make -C src clean
	make -C tests clean

pretty:
	make -C src pretty

test:
	make -C tests
