const fs=require('fs'),path=require('path');
const dir=__dirname,root=path.resolve(dir,'../../..');
const sourceRoot=process.argv.includes('--baseline')?path.join(dir,'baseline'):root;
const rtl=path.relative(dir,path.join(sourceRoot,'rtl')).replaceAll('\\','/');
const text=fs.readFileSync(path.join(sourceRoot,'rtl/vdp.vhd'),'utf8');
const width=Number(text.match(/ss_regs_out\s*:\s*out\s+STD_LOGIC_VECTOR\((\d+) downto/)[1])+1;
const overrides={clk_sys:'clk',reset_n:'rst',ce_vdp:'ce',gg:'gg_mode',hl:'hl',rd_n:'rd',wr_n:"'1'",a:'addr',d_out:'dout',x:'x',y:'"011001000"',ss_regs_out:'live',ss_regs_in:'saved',ss_regs_set:'load'};
const pairs=[...text.split('architecture')[0].matchAll(/\b(\w+)\s*:\s*(in|out)\s+(STD_LOGIC(?:_VECTOR\s*\([^)]*\))?)/gi)].map(m=>`${m[1]} => ${overrides[m[1].toLowerCase()]??(m[2].toLowerCase()==='out'?'open':m[3].toLowerCase().includes('vector')?"(others=>'0')":"'0'")}`);
const refpairs=pairs.map(p=>p.replace('HL => hl','HL => ref_hl').replace('x => x','x => ref_x').replace('D_out => dout','D_out => ref_dout').replace('ss_regs_out => live','ss_regs_out => open').replace('ss_regs_set => load',"ss_regs_set => '0'"));
fs.writeFileSync(path.join(dir,'hcounter_tb.vhd'),`library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
entity hcounter_tb is generic(expect_fixed: boolean := false; gg_mode: std_logic := '0'); end;
architecture test of hcounter_tb is
signal clk: std_logic := '0'; signal rst,hl,load,ce: std_logic := '0';
signal rd: std_logic := '1'; signal addr,dout: std_logic_vector(7 downto 0) := (others=>'0');
signal x: std_logic_vector(8 downto 0) := (others=>'0');
signal live,saved: std_logic_vector(${width-1} downto 0);
signal ref_hl: std_logic := '0'; signal ref_x: std_logic_vector(8 downto 0) := (others=>'0');
signal ref_dout: std_logic_vector(7 downto 0);
begin clk<=not clk after 5 ns;
dut: entity work.vdp port map(${pairs.join(',\n')});
reference: entity work.vdp port map(${refpairs.join(',\n')});
process
procedure tick is begin wait until rising_edge(clk); wait for 1 ns; end;
procedure latch_at(n: natural) is begin hl<='0';tick; x<=std_logic_vector(to_unsigned(n,9));hl<='1';tick;hl<='0';tick;end;
procedure read_h(want: natural) is begin rd<='1';ce<='1';tick;addr<=x"41";rd<='0';tick;
assert dout=std_logic_vector(to_unsigned(want,8)) report "HCounter mismatch actual="&integer'image(to_integer(unsigned(dout)))&" expected="&integer'image(want) severity failure;
rd<='1';tick;ce<='0';end;
variable point: natural;
begin tick;rst<='1';tick;
for n in 0 to 7 loop
case n is when 0=>point:=0; when 1=>point:=1; when 2=>point:=254; when 3=>point:=255; when 4=>point:=256; when 5=>point:=485; when 6=>point:=486; when others=>point:=511;end case;
ref_hl<='0';tick;ref_x<=std_logic_vector(to_unsigned(point,9));ref_hl<='1';tick;ref_hl<='0';tick;
latch_at(point); read_h(point/2);saved<=live;tick;
latch_at((point+96) mod 512);read_h(((point+96) mod 512)/2);
load<='1';tick;load<='0';tick;
if expect_fixed then read_h(point/2);assert dout=ref_dout report "reference replay HCounter mismatch" severity failure;
else read_h(((point+96) mod 512)/2);end if;
latch_at((point+2) mod 512);read_h(((point+2) mod 512)/2);
end loop;
${width>128?`-- Legacy controller supplies zero; simultaneous live HL must not override restore.
saved(135 downto 128)<=x"00";hl<='0';tick;
x<=std_logic_vector(to_unsigned(510,9));hl<='1';load<='1';tick;
load<='0';hl<='0';tick;read_h(0);
latch_at(510);read_h(255);`:''}
if expect_fixed then report "PASS: F07 fixed real latch/save/perturb/load/read, 8 boundaries and subsequent HL";
else report "REPRODUCED BEFORE FIX: load returns B instead of saved A, 8 boundaries";end if;
std.env.stop;wait;
end process;end;
`);
fs.writeFileSync(path.join(dir,'vdp.do'),`onerror {quit -code 1}
onbreak {resume}
vlib work
vcom -2008 -quiet ${rtl}/dpram.vhd ${rtl}/vdp_cram.vhd ${rtl}/vdp_background.vhd ${rtl}/vdp_sprite_shifter.vhd ${rtl}/vdp_sprites.vhd ${rtl}/vdp_main.vhd ${rtl}/vdp.vhd hcounter_tb.vhd
if {![info exists env(HCOUNTER_GG)]} {set env(HCOUNTER_GG) 0}
vsim -c -t 1ps -L altera_mf work.hcounter_tb -gexpect_fixed=$env(HCOUNTER_FIXED) -ggg_mode=$env(HCOUNTER_GG) -g/hcounter_tb/dut/vdp_vram_inst/init_file=UNUSED -g/hcounter_tb/reference/vdp_vram_inst/init_file=UNUSED
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
run -all
quit -code 0
`);
console.log('Generated test for '+width+'-bit production VDP interface');

