const fs=require('fs'),p=require('path');const d=__dirname;
const original=fs.readFileSync(p.join(d,'candidate/rtl/VM2413/registermemory.vhd'),'utf8');
fs.writeFileSync(p.join(d,'mapped_registermemory.vhd'),original.split(/architecture\s+rtl\b/i)[0]+`architecture mapped of RegisterMemory is
component RegisterMemory_gate is port(clk,reset:in std_logic;addr:in std_logic_vector(3 downto 0);wr:in std_logic;idata:in std_logic_vector(23 downto 0);odata:out std_logic_vector(23 downto 0));end component;
begin u:RegisterMemory_gate port map(clk,reset,addr,wr,idata,odata);end;
`);
fs.writeFileSync(p.join(d,'fm_gate_tb.vhd'),fs.readFileSync(p.join(d,'fm_tb.vhd'),'utf8').replaceAll('fm_tb','fm_gate_tb').replaceAll('candidate_work','mapped_work').replace('PASS full OPLL:','PASS full OPLL with mapped candidate RegisterMemory:'));
