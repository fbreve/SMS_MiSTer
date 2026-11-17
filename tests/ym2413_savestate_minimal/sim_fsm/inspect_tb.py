with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv', 'rb') as f:
    tb = f.read().decode('latin1')

idx = tb.find('[CHECK] Verificando se nota sustentada')
print(repr(tb[idx-20:idx+300]))

