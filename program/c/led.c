int main() {
    int sum = 0;
    for (int i = 1; i <= 5; ++i) {
        sum += i;
    }

    volatile int* led_ptr = (int*)0x0000007A;
    *led_ptr = sum;
    while (1);
    return 0;
}
