with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv') as f:
    text = f.read()

target = "        write_opll(8'h20, 8'h19);\n"
replacement = """        write_opll(8'h20, 8'h19);
        begin : probe_wait
            integer pw;
            for (pw = 0; pw < 500; pw = pw + 1) begin
                tick;
                if (dut_opll.ct.u_register_memory.regs_array[0] != 0) begin
                    $display("   [SUCCESS PROBE] regs_array[0] became %06h at tick %0d!", dut_opll.ct.u_register_memory.regs_array[0], pw);
                    disable probe_wait;
                end
            end
            $display("   [FAIL PROBE] regs_array[0] remained 0 after 500 ticks!");
        end
"""
assert target in text
text = text.replace(target, replacement, 1)

with open('tests/ym2413_savestate_minimal/sim_fsm/tb_ym2413_fsm_integration.sv', 'w') as f:
    f.write(text)
print("Probe script applied.")

