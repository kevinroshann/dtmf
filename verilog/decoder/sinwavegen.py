import math

FS = 8000.0
FREQ = 1477.0

for n in range(128):
    v = round(32767 * math.sin(2 * math.pi * FREQ * n / FS))
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

