with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv', 'rb') as f:
    data = f.read()

target1 = b".z80_m1_n(1'b1),"
repl1   = b".z80_m1_n(1'b0),"
target2 = b".z80_mreq_n(1'b1),"
repl2   = b".z80_mreq_n(1'b0),"

assert target1 in data
assert target2 in data

data = data.replace(target1, repl1, 1)
data = data.replace(target2, repl2, 1)

with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv', 'wb') as f:
    f.write(data)

print('Successfully updated z80_m1_n and z80_mreq_n to 0')

