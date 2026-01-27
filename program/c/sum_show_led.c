int main() {
    volatile int* led = (int*)0x0000007A;
    int sum = 0;

    for (int i = 1; i <= 10; ++i) {
        sum += i;
    }
    *led = sum;
    return 0;
}
