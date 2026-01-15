int calc_sum() {
    int sum = 0;
    for (int i = 1; i <= 10; i++) {
        sum += i;
    }
    return sum;
}

int main() {
    int result = calc_sum();
    return 0;
}
