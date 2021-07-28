TARGET	=	nop
SRCS	=	main.c
SRCS1	=	parser.c \
			scanner.c
OBJS	=	$(SRCS:.c=.o)
OBJS1	=	$(SRCS1:.c=.o)
CARGS	=	-g -O0 -Wall -Wextra -DPARSE_TRACE
#CARGS	=	-O3 -Wall -Wextra
INCDIRS	=	-I.
LIBDIRS	=	-L.
LIBS	=	-lreadline -lm
CC		=	gcc

.PHONY: all clean cleanmake

all: $(TARGET)

.c.o:
	$(CC) $(CARGS) $(INCDIRS) -c $< -o $@

$(TARGET): $(OBJS1) $(OBJS)
	$(CC) $(CARGS) -o $(TARGET) $(OBJS) $(OBJS1) $(LIBS)

parser.c parser.h: parser.y
	bison --report=all --graph=parser.dot -tvd --output=parser.c parser.y

scanner.c: scanner.l parser.h scanner.h
	flex -o scanner.c scanner.l

remake: clean all

clean:
	-rm -f $(TARGET) $(OBJS) $(OBJS1) $(SRCS1) parser.h parser.output parser.dot
