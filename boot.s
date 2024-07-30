.section .text
.global _start

_start:
    cli
    cld
    call kernel_main

    hlt
