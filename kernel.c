#include <stdint.h>

void kernel_main() {
    const char *str = "Hello, Kernel!";
    uint16_t *video_memory = (uint16_t *)0xB8000;
    uint16_t color = 0x0F00; // white on black

    for (size_t i = 0; str[i] != '\0'; i++) {
        video_memory[i] = (color | str[i]);
    }

    while (1) {
        // Halt the CPU to save power
        __asm__ __volatile__("hlt");
    }
}
