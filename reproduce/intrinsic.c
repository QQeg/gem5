#include <stdint.h>
#include <stdio.h>
#include <riscv_vector.h>

// Set vlen to 256, elen to 64
int main() {
    uint8_t print_buffer[32];

    // Since the data type is int8_t, vl is fixed to 32(vlmax)
    size_t vl = 32;

    // Assign a value of one to each element in the input vector register Vs1
    vint8m1_t Vs1 = __riscv_vmv_v_x_i8m1(1, vl);

    // Store Vs1 to buffer and print it out
    __riscv_vse8_v_i8m1(print_buffer, Vs1, vl);
    printf("First four elements of Vs1 = ");
    for (int i = 0; i < vl / 8; ++i) {
        printf("%d ", print_buffer[i]);
    }
    printf("\n");

    // The instruction that produce an incorrect output on gem5 when vl is set to 0
    vbool8_t Vd = __riscv_vmadc_vx_i8m1_b8(Vs1, UINT8_MAX, 0);

    // Store Vd to buffer and print it out
    __riscv_vsm_v_b8(print_buffer, Vd, vl);

    // Since the output of vmadc is of data type vbool8_t,
    // only the first vl / 8 elements (i.e. first 32 bits) of Vd are significant.
    // When vl is set to 0 in vmadc, the first 4 elements of Vd should be the same as Vs1,
    // which is 1111 in this case. However, the output is 0000.
    printf("First four elements of Vd  = ");
    for (int i = 0; i < vl / 8; ++i) {
        printf("%d ", print_buffer[i]);
    }
    printf("\n");

    return 0;
}