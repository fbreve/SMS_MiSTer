import glob

vhd_files = glob.glob('rtl/VM2413/*.vhd')
for vf in vhd_files:
    with open(vf, 'rb') as f:
        text = f.read().decode('latin1')
    if "'range" in text:
        lines = text.splitlines()
        for i, l in enumerate(lines):
            if "'range" in l:
                print(f"{vf}:{i+1}: {l.strip()}")

