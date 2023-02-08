# RISC-V Benchmarks


* `simple-programs`: Contains some simple benchmark programs
* `individual-instructions`: Contains RISC-V tests for each instruction

There are several files for each benchmark.  
I recommend each group to create your own tests to ensure that your processor implementation is correct.
* `.c`: The C program
* `.x`: The executable file that your processor will load
* `.d`: The dump file generated using GCC.  This has the addresses, the instruction encoding, and its assembly.
* `.s`: The assembly 

# Compiling your own toolchain

To build the compiler toolchain, you can follow the instructions [riscv-gnu-toolchain](https://riscv.org/software-tools/risc-v-gnu-compiler-toolchain/).

A few compile options specific for our course.
```
$ git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
$ ./configure --prefix=/opt/riscv --with-arch=rv32i --with-abi=ilp32
$ make
```
The `--with-arch=rv32i` informs the build scripts to include the base RISC-V ISA, and `--with-abi=ilp32` refers to the software version of the floating point. 
The binaries will be placed in `/opt/riscv` (on a successful build).

