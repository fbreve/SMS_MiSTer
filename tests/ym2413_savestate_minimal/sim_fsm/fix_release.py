with open('rtl/VM2413/vm2413.vhd', 'rb') as f:
    text = f.read().decode('latin1')

# Replace constant Release with \Release\
target = 'constant Release : EGSTATE_TYPE := "11";'
replacement = 'constant \\Release\\ : EGSTATE_TYPE := "11";'

if target in text:
    text = text.replace(target, replacement)
    with open('rtl/VM2413/vm2413.vhd', 'wb') as f:
        f.write(text.encode('latin1'))
    print('Escaped \\Release\\ successfully')
else:
    print('Target not found!')

