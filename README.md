
# Basic Mobile OS

## Overview
This project aims to create a very basic mobile operating system from scratch. It includes a simple bootloader, kernel, basic device drivers, system libraries, a command-line shell, and a minimal graphical user interface.

## Project Structure
```
/BasicMobileOS
├── boot.s
├── grub.cfg
├── kernel.c
├── Makefile
├── shell.c
├── stdlib.c
└── README.md
```

## Components

### Bootloader
The bootloader initializes the hardware and loads the kernel into memory. We use GRUB for this purpose.

**`grub.cfg`**:
```cfg
set timeout=5
set default=0

menuentry "My OS" {
    multiboot2 /boot/myos.kernel
    boot
}
```

### Kernel
The kernel is responsible for managing hardware resources and providing core system functionalities.

**`kernel.c`**:
```c
#include <stdint.h>

void kernel_main() {
    const char *str = "Hello, Kernel!";
    uint16_t *video_memory = (uint16_t *)0xB8000;
    uint16_t color = 0x0F00;

    for (size_t i = 0; str[i] != '\0'; i++) {
        video_memory[i] = (color | str[i]);
    }

    while (1) {
        __asm__ __volatile__("hlt");
    }
}
```

### Makefile
The Makefile automates the build process.

**`Makefile`**:
```makefile
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
```

### Bootloader Assembly
**`boot.s`**:
```asm
.section .text
.global _start

_start:
    cli
    cld
    call kernel_main

    hlt
```

### System Libraries
Basic system libraries for memory operations.

**`stdlib.c`**:
```c
void *memset(void *s, int c, size_t n) {
    unsigned char *p = s;
    while (n--) {
        *p++ = (unsigned char)c;
    }
    return s;
}

void *memcpy(void *dest, const void *src, size_t n) {
    unsigned char *d = dest;
    const unsigned char *s = src;
    while (n--) {
        *d++ = *s++;
    }
    return dest;
}
```

### Shell
A simple command-line interface for user interaction.

**`shell.c`**:
```c
#include <stddef.h>
#include <stdint.h>

#define VGA_WIDTH 80
#define VGA_HEIGHT 25

static size_t terminal_row;
static size_t terminal_column;
static uint8_t terminal_color;
static uint16_t *terminal_buffer;

void terminal_initialize(void) {
    terminal_row = 0;
    terminal_column = 0;
    terminal_color = 0x0F;
    terminal_buffer = (uint16_t *)0xB8000;
    for (size_t y = 0; y < VGA_HEIGHT; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            const size_t index = y * VGA_WIDTH + x;
            terminal_buffer[index] = (uint16_t)terminal_color << 8 | ' ';
        }
    }
}

void terminal_putchar(char c) {
    const size_t index = terminal_row * VGA_WIDTH + terminal_column;
    terminal_buffer[index] = (uint16_t)terminal_color << 8 | c;
    if (++terminal_column == VGA_WIDTH) {
        terminal_column = 0;
        if (++terminal_row == VGA_HEIGHT) {
            terminal_row = 0;
        }
    }
}

void terminal_write(const char *data, size_t size) {
    for (size_t i = 0; i < size; i++) {
        terminal_putchar(data[i]);
    }
}

void kernel_main(void) {
    terminal_initialize();
    const char *message = "Simple Shell> ";
    terminal_write(message, 14);

    while (1) {
        __asm__ __volatile__("hlt");
    }
}
```

## Building the OS
To compile the OS, run the following command:
```sh
make
```

## Running the OS
To run the OS using QEMU, execute:
```sh
qemu-system-x86_64 -kernel myos.kernel
```

## Future Improvements
- Implement more device drivers.
- Expand system libraries for more functionalities.
- Develop a more complex graphical user interface.
- Create more advanced applications to demonstrate the OS capabilities.

## Contributing
Contributions are welcome! Please feel free to submit a pull request or open an issue if you have any suggestions or improvements.

## License
This project is licensed under the MIT License.
