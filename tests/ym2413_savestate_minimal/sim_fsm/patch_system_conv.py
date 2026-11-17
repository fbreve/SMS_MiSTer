with open('rtl/system.vhd', 'rb') as f:
    text = f.read().decode('latin1')

target1 = "conv_integer(fm_state_addr)=31"
replacement1 = "fm_state_addr = x\"1F\""

target2 = "conv_integer(fm_state_addr) = 31"
replacement2 = "fm_state_addr = x\"1F\""

assert target1 in text, "target1 not found"
text = text.replace(target1, replacement1)

assert target2 in text, "target2 not found"
text = text.replace(target2, replacement2)

with open('rtl/system.vhd', 'wb') as f:
    f.write(text.encode('latin1'))

print("Updated system.vhd successfully!")

