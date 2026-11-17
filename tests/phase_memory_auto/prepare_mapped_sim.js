const fs=require('fs'),p=require('path');const d=__dirname;
const original=fs.readFileSync(p.join(d,'candidate/rtl/VM2413/phasememory.vhd'),'utf8');
fs.writeFileSync(p.join(d,'mapped_phasememory.vhd'),original.split('architecture RTL')[0]+`architecture mapped of PhaseMemory is
component PhaseMemory_gate is port(clk,reset:in std_logic;slot:in std_logic_vector(4 downto 0);memwr:in std_logic;memout:out std_logic_vector(17 downto 0);memin:in std_logic_vector(17 downto 0));end component;
begin u:PhaseMemory_gate port map(clk,reset,slot,memwr,memout,memin);end;
`);
fs.writeFileSync(p.join(d,'fm_gate_tb.vhd'),fs.readFileSync(p.join(d,'fm_tb.vhd'),'utf8').replaceAll('fm_tb','fm_gate_tb').replaceAll('candidate_work','mapped_work').replace('PASS full OPLL:','PASS full OPLL with mapped candidate PhaseMemory:'));
