import os

replacements = {
    'rtl/savestates.sv': [
        (
            b'// FM (YM2413 / OPLL) Savestate Extension (Approach C: 16 x 64-bit words = 32 x 32-bit registers)',
            b'// FM (YM2413 / OPLL) Savestate Extension: 16 x 64-bit words (32 x 32-bit registers)'
        )
    ],
    'rtl/VM2413/controller.vhd': [
        (
            b'-- Approach C private, fixed-latency 32-bit access',
            b'-- Savestate private fixed-latency 32-bit state access interface'
        )
    ],
    'rtl/VM2413/envelopegenerator.vhd': [
        (
            b'-- Approach C private, fixed-latency 32-bit access',
            b'-- Savestate private fixed-latency 32-bit state access interface'
        )
    ],
    'rtl/VM2413/envelopememory.vhd': [
        (
            b'-- Approach C private, fixed-latency 32-bit access',
            b'-- Savestate private fixed-latency 32-bit state access interface'
        )
    ],
    'rtl/VM2413/opll.vhd': [
        (
            b'-- Approach C private, fixed-latency 32-bit access',
            b'-- Savestate private fixed-latency 32-bit state access interface'
        )
    ],
    'rtl/VM2413/registermemory.vhd': [
        (
            b'-- Approach C private, fixed-latency 32-bit access',
            b'-- Savestate private fixed-latency 32-bit state access interface'
        )
    ],
    'rtl/VM2413/voicememory.vhd': [
        (
            b'-- Approach C private, fixed-latency 32-bit access',
            b'-- Savestate private fixed-latency 32-bit state access interface'
        )
    ]
}

for path, pairs in replacements.items():
    with open(path, 'rb') as f:
        data = f.read()
    for target, repl in pairs:
        assert target in data, f'Target not found in {path}: {target}'
        data = data.replace(target, repl, 1)
    with open(path, 'wb') as f:
        f.write(data)
    print(f'Cleaned comments in {path}')

print('Comment cleanup complete!')

