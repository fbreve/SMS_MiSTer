with open('rtl/VM2413/controller.vhd', 'rb') as f:
    data = f.read()

# 1. Replace ch_type'range with 0 to 8
assert b"ch_type'range" in data
data = data.replace(b"ch_type'range", b"0 to 8")

# 2. Add when others to addr(2 downto 1)
target_addr_end = b'''                                when others => null;
                        end case;'''
# Let's find addr(2 downto 1)
p_addr = data.find(b'addr(2 downto 1)')
p_end_addr = data.find(b'end case;', p_addr)

# Check if there is already a when others
addr_block = data[p_addr:p_end_addr+9]
if b'when others' not in addr_block:
    data = data[:p_end_addr] + b'when others => null;\r\n                        ' + data[p_end_addr:]

# 3. Add when others to stage case
p_stage = data.find(b'case stage is')
# The stage case ends after all 4 stages
p_end_stage = data.find(b'end case;', p_stage)
# But wait, stage case has inner case, so let's find the stage end case
p_stage4 = data.find(b'when "11" =>', p_stage)
p_end_stage = data.find(b'end case;', p_stage4)
stage_block = data[p_stage4:p_end_stage+9]
if b'when others' not in stage_block:
    data = data[:p_end_stage] + b'when others => null;\r\n            ' + data[p_end_stage:]

with open('rtl/VM2413/controller.vhd', 'wb') as f:
    f.write(data)

print('Updated controller.vhd with ch_type array fix and when others')

