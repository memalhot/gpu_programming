# Makefile for building hello.cu with nvcc

# Compiler
NVCC = nvcc

# Compiler flags
GENCODE = -gencode arch=compute_70,code=sm_70

# Targets
TARGET = siggen
SRC = siggen.cu

# Default rule
all: $(TARGET)

$(TARGET): $(SRC)
	$(NVCC) $(GENCODE) $< -o $@

# Clean rule
clean:
	rm -f $(TARGET)
	rm -f \#*\#
	rm *~
