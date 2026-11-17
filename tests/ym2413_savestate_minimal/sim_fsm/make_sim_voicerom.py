import os

sim_dir = 'tests/ym2413_savestate_minimal/sim_fsm'
os.makedirs(f'{sim_dir}/sim_vhd', exist_ok=True)
with open('rtl/VM2413/voicerom.vhd', 'rb') as f:
    text = f.read()

text = text.replace(b"array (VOICE_ID_TYPE'range)", b"array (0 to 37)")
with open(f'{sim_dir}/sim_vhd/voicerom.vhd', 'wb') as f:
    f.write(text)

print('Created test-only adaptation of voicerom.vhd')

