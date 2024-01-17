#include <stdint.h>
#include <stdio.h>
#include <riscv_vector.h>

// Set vlen to 256, elen to 64
int main() {
    uint8_t print_buffer[32];
    size_t vl = 32;
    vint8mf8_t Vs1 = vmv_v_x_i8mf8(1, vl);
    vse8_v_i8mf8(print_buffer, Vs1, vl);

    printf("First four elements of Vs1 = ");
    for (int i = 0; i < vl / 8; ++i) {
        printf("%d ", print_buffer[i]);
    }
    printf("\n");

    // Set LMUL to 1/8
    vbool64_t Vd = vmadc_vx_i8mf8_b64(Vs1, UINT8_MAX, 4);
    vsm_v_b64(print_buffer, Vd, vl);

    printf("First four elements of Vd  = ");
    for (int i = 0; i < vl / 8; ++i) {
        printf("%d ", print_buffer[i]);
    }
    printf("\n");

    return 0;
}