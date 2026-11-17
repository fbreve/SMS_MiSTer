const fs=require('fs'),p=require('path'),cp=require('child_process'),assert=require('assert'),d=__dirname;
const a=fs.readFileSync(p.join(d,'seed1/A/rtl/memory_decode.vhd'),'utf8'),c=fs.readFileSync(p.join(d,'seed1/C/rtl/memory_decode.vhd'),'utf8');
const ports=[...a.slice(a.indexOf('port ('),a.indexOf('end entity')).matchAll(/(\w+)\s*:\s*(in|out)\s+(std_logic(?:_vector\([^)]*\))?)/g)];
let s='library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all; entity tb is end; architecture sim of tb is\n';
for(const [,n,dir,t]of ports)for(const suffix of dir==='in'?['']:['_a','_c'])s+=`signal ${n}${suffix}: ${t} := ${t==='std_logic'?"'0'":"(others=>'0')"};\n`;
s+='begin\n';for(const [lib,suffix]of [['base','_a'],['cand','_c']])s+=`u${lib}: entity ${lib}.memory_decode port map (${ports.map(([,n,dir])=>n+'=>'+n+(dir==='out'?suffix:'')).join(',')});\n`;
s+=`process
variable expected,bank: integer;
procedure check is begin
assert rom_a_i_out_a=rom_a_i_out_c and cart_precedence_out_a=cart_precedence_out_c and cart_memory_selected_out_a=cart_memory_selected_out_c and dahjee_cart_access_out_a=dahjee_cart_access_out_c report "RTL mismatch" severity failure;
end;
begin
bootloader_n<='1'; dbr<='1';
-- Every selector equivalence class and every selected bank value. Distinct
-- bijections also catch accidental selection of a different bank register.
for flags in 0 to 3 loop
mapper_4pak<=std_logic(to_unsigned(flags,2)(1)); mapper_codies<=std_logic(to_unsigned(flags,2)(0));
for page in 0 to 63 loop
for b in 0 to 255 loop
A<=std_logic_vector(to_unsigned(page*1024,16));
bank0<=std_logic_vector(to_unsigned(b,8)); bank1<=std_logic_vector(to_unsigned((b+85) mod 256,8)); bank2<=std_logic_vector(to_unsigned((b+170) mod 256,8));
wait for 1 ns; check;
if page<16 then bank:=b; elsif page<32 then bank:=(b+85) mod 256; else bank:=(b+170) mod 256; end if;
if flags=0 and page=0 then bank:=0; end if;
expected:=bank*16384+(page*1024 mod 16384);
assert to_integer(unsigned(rom_a_i_out_c))=expected report "Mapper contract mismatch" severity failure;
end loop; end loop; end loop;
-- All byte addresses, including 0038/0066/03ff/0400 boundaries, each mapper.
for flags in 0 to 3 loop
mapper_4pak<=std_logic(to_unsigned(flags,2)(1)); mapper_codies<=std_logic(to_unsigned(flags,2)(0));
bank0<=x"35"; bank1<=x"a6"; bank2<=x"f1";
for address in 0 to 65535 loop A<=std_logic_vector(to_unsigned(address,16)); wait for 1 ns; check; end loop;
end loop;
report "PASS 327680 binary RTL comparisons; 65536 independent mapper contract checks";
wait;
end process; end;`;
s=s.replace('architecture sim of tb is','library base; library cand; architecture sim of tb is');
fs.writeFileSync(p.join(d,'tb.vhd'),s);
const bin='C:/intelFPGA_lite/17.0/modelsim_ase/win32aloem/';
function run(ex,args){const r=cp.spawnSync(bin+ex+'.exe',args,{cwd:d,encoding:'utf8'});fs.appendFileSync(p.join(d,'functional.log'),r.stdout+r.stderr);assert.equal(r.status,0,ex);}
assert(!fs.existsSync(p.join(d,'functional.log')));
for(const lib of ['base','cand','work'])run('vlib',[lib]);
run('vcom',['-2008','-work','base','seed1/A/rtl/memory_decode.vhd']);run('vcom',['-2008','-work','cand','seed1/C/rtl/memory_decode.vhd']);run('vcom',['-2008','tb.vhd']);run('vsim',['-c','work.tb','-do','onerror {quit -code 1}; onbreak {quit -code 1}; run 400 us; quit -code 0']);
assert(fs.readFileSync(p.join(d,'functional.log'),'utf8').includes('PASS 327680'));
console.log('Functional RTL comparison PASS');
