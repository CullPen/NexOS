.PHONY: all clean

all: myos.kernel

myos.kernel: boot.o kernel.o
    ld -o myos.kernel -Ttext 0x1000 --oformat binary boot.o kernel.o

boot.o: boot.s
    as --32 -o boot.o boot.s

kernel.o: kernel.c
    gcc -m32 -ffreestanding -c kernel.c -o kernel.o

clean:
    rm -f *.o myos.kernel
