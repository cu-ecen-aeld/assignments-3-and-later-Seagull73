# Makefile for building writer.c

CC := $(CROSS_COMPILE)gcc
CFLAGS := -Wall -g -O2

# Target binary and object files
TARGET := writer
OBJS := writer.o

.PHONY: all clean

# Default target
all: $(TARGET)

# Link target
$(TARGET): $(OBJS)
	@ $(CC) $(CFLAGS) -o $@ $^

# Compile object files
%.o: %.c
	@ $(CC) $(CFLAGS) -c $< -o $@

# Clean target
clean:
	@ rm -f $(TARGET) *.o