import hashlib

files = [
    'SMS.sv',
    'rtl/savestates.sv',
    'rtl/system.vhd',
    'rtl/VM2413/controller.vhd',
    'rtl/VM2413/envelopegenerator.vhd',
    'rtl/VM2413/envelopememory.vhd',
    'rtl/VM2413/opll.vhd',
    'rtl/VM2413/registermemory.vhd',
    'rtl/VM2413/voicememory.vhd',
    'rtl/VM2413/voicerom.vhd'
]

lines = []
for f in files:
    with open(f, 'rb') as fp:
        h = hashlib.sha256(fp.read()).hexdigest()
        lines.append(f'{h}  {f}')
        print(f'{h}  {f}')

composite = hashlib.sha256('\n'.join(lines).encode('utf-8')).hexdigest()
print('COMPOSITE_SOURCE_TREE_SHA256:', composite)

