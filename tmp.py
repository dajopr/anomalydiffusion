def expected_number_of_flips(n, p=0.5):
    if n == 1:
        return 2
    flips = (expected_number_of_flips(n - 1) + 1) * 1 / p
    return flips


for n in range(1, 10):
    print(f"{n}: {expected_number_of_flips(n)}")
