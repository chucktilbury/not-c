################################################################################
#
#	Make file for simple objects
#
################################################################################
PLATNAME := $(shell uname)

OBJS	=	ast.o \
			errors.o \
			main.o \
			memory.o \
			symbols.o \
			constants.o

OBJS1	=	scanner.o \
			parser.o

SRCS	=	$(OBJS:.o=.c)
SRCS1	=	$(OBJS1:.o=.c)
HEADERS	=	$(OBJS:.o=.h)

TARGET	=	nop
DEPS	= 	$(TARGET).dep

CC		=	gcc # clang
CARGS	=	-Wall -Wextra
HSRC	= 	-I.

# comment this out to disable messages
DEBUG	=	-g -DTRACE

.PHONY: all pretty clean all_clean

all: $(TARGET)

.c.o:
	$(CC) $(HSRC) $(CARGS) $(DEBUG) -c $< -o $@

$(TARGET): $(OBJS1) $(OBJS)
	$(CC) $(DEBUG) $(CARGS) -o $(TARGET) $(OBJS) $(OBJS1)

parser.c parser.h: parser.y scanner.h
	bison --report=lookahead -tvdo parser.c parser.y

scanner.c: scanner.l parser.h scanner.h
	flex -o scanner.c scanner.l

pretty:
	indent $(SRCS) $(HEADERS)
	-rm -f *~

clean:
	-rm -f parser.output $(OBJS) $(OBJS1) *.bak *~

all_clean: clean
	-rm -f scanner.c parser.c parser.h $(TARGET) $(DEPS) .indent.pro

-include $(DEPS)
