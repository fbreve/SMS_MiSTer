"""Generate small fixtures around unmodified production entities; run from repo root."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[2]
out = Path(__file__).resolve().parent

def fixture(entity, overrides):
    src = (root / f'rtl/{entity}.vhd').read_text()
    ports = src.split('architecture', 1)[0]
    pairs = []
    for name, direction, typ in re.findall(r'\b(\w+)\s*:\s*(in|out)\s+(STD_LOGIC(?:_VECTOR\s*\([^)]*\))?)', ports, re.I):
        val = overrides.get(name.lower(), 'open' if direction.lower() == 'out' else "(others=>'0')" if 'vector' in typ.lower() else "'0'")
        pairs.append(f'{name} => {val}')
    return f'entity work.{entity} port map(' + ',\n'.join(pairs) + ');'

io = fixture('io', dict(clk='clk', reset_n='rst', ce_cpu="'1'", wr_n='wr', rd_n='rd', a='addr', d_in='din', d_out='dout', gg="'1'", gg_link_en="'1'", gg_link_in="(others=>'1')", gg_state_out='ggsnap', gg_state_in='ggsaved', gg_state_set='load', io_state_out='snap', io_state_in='saved', io_state_set='load', ss_freeze='freeze'))
(out/'io_gap_tb.vhd').write_text('''library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity io_gap_tb is end; architecture test of io_gap_tb is
signal clk: std_logic := '0'; signal rst: std_logic := '0';
signal wr,rd: std_logic := '1'; signal load,freeze: std_logic := '0';
signal addr,din,dout: std_logic_vector(7 downto 0) := (others=>'0');
signal snap,saved: std_logic_vector(31 downto 0);
signal ggsnap,ggsaved: std_logic_vector(127 downto 0);
begin clk <= not clk after 5 ns;
dut: '''+io+'''
process
procedure tick is begin wait until rising_edge(clk); wait for 1 ns; end;
procedure put(a,d: natural) is begin addr<=std_logic_vector(to_unsigned(a,8)); din<=std_logic_vector(to_unsigned(d,8)); wr<='0'; tick; wr<='1'; tick; end;
begin tick; rst<='1'; tick;
put(2,0); put(1,16#35#); saved<=snap; ggsaved<=ggsnap; tick;
put(1,16#6A#); freeze<='1'; load<='1'; tick; load<='0'; freeze<='0'; tick;
addr<=x"01"; rd<='0'; tick; tick;
assert dout=x"35" report "GG PDR restore failed" severity failure;
report "PASS io_gap_tb (F02 fixed: saved 35, perturbed 6A, restored 35)"; std.env.stop; wait;
end process; end;
''')

eep1=fixture('eeprom_93c46',dict(clk_sys='clk',reset_n='rst',cs_in="'1'",clk_in='serial',di='din',nvram_do='x"FF"',ss_out='snap',ss_in='saved',ss_set='load',ss_ext_out='ext',ss_ext_in='saved_ext',ss_full="'1'"))
eep2=fixture('eeprom_93c46',dict(clk_sys='clk',reset_n='rst',cs_in="'1'",clk_in='serial',di='din',nvram_do='x"FF"',ss_out='ref_snap'))
(out/'eeprom_gap_tb.vhd').write_text('''library ieee; use ieee.std_logic_1164.all;
entity eeprom_gap_tb is end; architecture test of eeprom_gap_tb is
signal clk: std_logic := '0'; signal rst,serial,din,load: std_logic := '0';
signal ext,saved_ext: std_logic_vector(127 downto 0);
signal snap,ref_snap,saved: std_logic_vector(63 downto 0);
begin clk<=not clk after 5 ns;
dut: '''+eep1+'\nreference: '+eep2+'''
process
procedure tick is begin wait until rising_edge(clk); wait for 1 ns; end;
procedure bit_in(b: std_logic) is begin serial<='0'; din<=b; tick; tick; serial<='1'; tick; tick; serial<='0'; tick; end;
begin tick; rst<='1'; tick;
bit_in('1'); -- start
bit_in('0'); bit_in('0'); bit_in('1'); bit_in('1'); -- first half of EWEN
saved<=snap; saved_ext<=ext; tick; load<='1'; tick; load<='0'; tick;
bit_in('0'); bit_in('0'); bit_in('0'); bit_in('0'); -- finish opcode 00110000
assert ref_snap(1)='1' and snap(1)='1' report "F03 full protocol restore failed" severity failure;
report "F03 restored partial EWEN: reference and DUT EWEN=1";
report "PASS eeprom_gap_tb (F03 fixed)"; std.env.stop; wait;
end process; end;
''')
(out/'md_gap_tb.sv').write_text('''module md_gap_tb;
reg clk=0, refclk=0, runref=1, reset=1, th=1, freeze=0,ss_set=0;
always #5 begin clk=~clk; if(runref) refclk=~refclk; end
wire [5:0] pins,refpins;wire [11:0]state,refstate;reg[11:0]saved;
sega_controller #(.TIMEOUT_CYCLES(64)) dut(clk,reset,2'd2,6'b111111,th,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1,pins,freeze,ss_set,1'b1,saved,state);
sega_controller #(.TIMEOUT_CYCLES(64)) reference(refclk,reset,2'd2,6'b111111,th,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1,refpins,1'b0,1'b0,1'b0,12'd0,refstate);
initial begin
 repeat(4) @(negedge clk); reset=0;
 repeat(3) begin th=0; repeat(3) @(negedge clk); th=1; repeat(3) @(negedge clk); end
 if(pins!==6'b110000) $fatal(1,"setup failed");
 saved=state;runref=0;repeat(70)@(negedge clk);
 if(pins!==6'b111111 || refpins!==6'b110000)$fatal(1,"perturbation missing");
 freeze=1;ss_set=1;@(negedge clk);ss_set=0;
 if(pins!==refpins||state!==saved)$fatal(1,"F08 restore failed");
 $display("PASS md_gap_tb (original F08 scenario now restores third-rise XYZ/Mode)");$finish;
end endmodule
''')
do='''onerror {quit -code 1}
onbreak {resume}
vlib work
vcom -2008 -quiet ../../rtl/io.vhd ../../rtl/eeprom_93c46.vhd io_gap_tb.vhd eeprom_gap_tb.vhd
vlog -sv -quiet ../../rtl/sega_controller.sv md_gap_tb.sv
vsim -c -t 1ps work.io_gap_tb
run -all
quit -sim
vsim -c -t 1ps work.eeprom_gap_tb
run -all
quit -sim
vsim -c -t 1ps work.md_gap_tb
run -all
quit -code 0
'''
(out/'run.do').write_text(do)
print('Generated three directed defect reproductions.')
