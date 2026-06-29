import math

FS = 8000.0
FREQ1 = 770.0
FREQ2 = 1633.0
AMP = 16383

for n in range(128):
    v = round(
        AMP * math.sin(2 * 3.14* FREQ1 * n / FS) +
        AMP * math.sin(2 * 3.14 * FREQ2 * n / FS)
    )

    if v >= 0:
        print(f"7'd{n}: sample = 16'sd{v};")
    else:
        print(f"7'd{n}: sample = -16'sd{abs(v)};")


# 941-941
# 697-770
# 770 - 852
#852-697
#1209-852
#1336 -941

