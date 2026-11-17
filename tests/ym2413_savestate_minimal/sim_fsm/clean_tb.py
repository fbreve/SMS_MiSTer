with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv') as f:
    lines = f.readlines()

part1 = lines[:117]
part2 = lines[122:]

text = ''.join(part1 + part2)

target_probe = """        write_opll(8'h20, 8'h19);
            end
            $display("   [FAIL PROBE] regs_array[0] remained 0 after 500 ticks!");
        end"""

clean_probe = """        write_opll(8'h20, 8'h19);"""

assert target_probe in text
text = text.replace(target_probe, clean_probe, 1)

with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv', 'w') as f:
    f.write(text)
print("Cleaned up successfully.")

