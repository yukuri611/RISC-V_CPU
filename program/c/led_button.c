int main() {
    int sum = 0;
    volatile int* led = (int*)0x00000007A;
    volatile int* button = (int*)0x0000007B;
    while (!(*button)) {
        sum++;
    }
    return 0;
}
