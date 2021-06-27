
SRCS	=	structs1.nop \
			structs2.nop \
			structs3.nop \
			structs4.nop \
			structs5.nop \
			structs6.nop \
			structs7.nop \
			structs8.nop \
			funcs1.nop \
			funcs2.nop \
			funcs3.nop \
			funcs4.nop \
			funcs5.nop \
			funcs6.nop \
			funcs7.nop \
			funcs8.nop \
			funcs9.nop \
			funcs10.nop \
			funcs11.nop \
			duplicates.nop \
			tree.nop \
			greatest_common_denominator.nop \
			recursion.nop \
			fibonacci.nop \
			primes.nop

.PHONY: all check clean

all:
	@for i in $(SRCS); do \
		../src/nop $${i} > $${i}.out 2>&1; \
		diff $${i}.out ./check/$${i}.check; \
		if [ $$? -eq 0 ]; then \
			echo "test $${i} PASSED"; \
			rm $${i}.out; \
		else \
			echo "test $${i} FAILED"; \
		fi; \
	done;

check:
	@for i in $(SRCS); do \
		echo "create check for $${i}"; \
		../src/nop $${i} > ./check/$${i}.check 2>&1; \
	done;

clean:
	-rm -f *.out
