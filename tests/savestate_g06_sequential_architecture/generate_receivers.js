const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
const sourceRoot=process.argv[2]?p.resolve(process.argv[2]):p.join(d,'baseline'),destRoot=process.argv[3]?p.resolve(process.argv[3]):p.join(d,'candidate_A');
assert(destRoot.startsWith(d+p.sep),'isolate generated sources inside experiment');
const read=f=>fs.readFileSync(p.join(sourceRoot,f),'utf8').replace(/\r\n/g,'\n'),write=(f,s)=>{const q=p.join(destRoot,f);fs.mkdirSync(p.dirname(q),{recursive:true});fs.writeFileSync(q,s);};
const ports=`
 ss_state_addr: in std_logic_vector(7 downto 0) := (others=>'0');
 ss_state_read: in std_logic := '0';
 ss_state_write: in std_logic := '0';
 ss_state_wdata: in std_logic_vector(31 downto 0) := (others=>'0');
 ss_state_rdata: out std_logic_vector(31 downto 0);
`;
const generic='\n        SS_SEQUENTIAL: boolean := true;';
const ROOT_REGISTER=!process.argv.includes('--distributed-response');
const sensitivity=e=>['ss_state_addr','ss_state_read',...['shift0','shift1','shift2','shift3','wideclock','enable','spr_x','spr_d0','spr_d1','spr_d2','spr_d3','data_address','m2_flags','color_reg','collide_reg','overflow_reg','xspr_collide_shift'].filter(n=>new RegExp('\\b'+n+'\\b').test(e))].join(',');
const use=s=>s.replace('use IEEE.STD_LOGIC_1164.ALL;','use IEEE.STD_LOGIC_1164.ALL;\nuse work.sprite_state_pkg.all;');
const localRead=(expressions)=>ROOT_REGISTER?`process(${sensitivity(expressions)})\nvariable r:std_logic_vector(31 downto 0);\nbegin\nr:=(others=>'0');\nif SS_SEQUENTIAL and ss_state_read='1' then\n${expressions}\nend if;\nss_local_data<=r;\nend process;\n`:`process(clk_sys)\n variable r: std_logic_vector(31 downto 0);\nbegin\n if rising_edge(clk_sys) then\n r := (others=>'0');\n if SS_SEQUENTIAL and ss_state_read='1' then\n${expressions}\n end if;\n ss_local_data <= r;\n end if;\nend process;\n`;
const ext=(value,base)=>`r := r or ss_extract(${value},${base},ss_state_addr);`;
const put=(value,base,bool=false)=>`${value} <= ss_merge${bool?'_bool':''}(${value},${base},ss_state_addr,ss_state_wdata);`;
const passthrough=`ss_state_addr=>ss_state_addr,ss_state_read=>ss_state_read,ss_state_write=>ss_state_write,ss_state_wdata=>ss_state_wdata,ss_state_rdata=>ss_child_data,`;
write('rtl/sprite_state_pkg.vhd',`library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package sprite_state_pkg is
 function ss_bool(value:boolean) return std_logic_vector;
 function ss_extract(value:std_logic_vector; base:integer; address:std_logic_vector) return std_logic_vector;
 function ss_merge(value:std_logic_vector; base:integer; address:std_logic_vector; data:std_logic_vector(31 downto 0)) return std_logic_vector;
 function ss_merge_bool(value:boolean; base:integer; address:std_logic_vector; data:std_logic_vector(31 downto 0)) return boolean;
 procedure ss_install(signal target:inout std_logic_vector; base:integer; address:std_logic_vector; data:std_logic_vector(31 downto 0));
 procedure ss_install_bool(signal target:inout boolean; base:integer; address:std_logic_vector; data:std_logic_vector(31 downto 0));
end package;
package body sprite_state_pkg is
 function ss_bool(value:boolean) return std_logic_vector is variable r:std_logic_vector(0 downto 0);begin if value then r(0):='1';else r(0):='0';end if;return r;end;
 function ss_extract(value:std_logic_vector; base:integer; address:std_logic_vector) return std_logic_vector is
 variable r:std_logic_vector(31 downto 0):=(others=>'0');begin
 for b in value'range loop if (base+b)/32=to_integer(unsigned(address)) then r((base+b) mod 32):=value(b);end if;end loop;return r;end;
 function ss_merge(value:std_logic_vector; base:integer; address:std_logic_vector; data:std_logic_vector(31 downto 0)) return std_logic_vector is variable r:std_logic_vector(value'range):=value;begin
 for b in value'range loop if (base+b)/32=to_integer(unsigned(address)) then r(b):=data((base+b) mod 32);end if;end loop;return r;end;
 function ss_merge_bool(value:boolean; base:integer; address:std_logic_vector; data:std_logic_vector(31 downto 0)) return boolean is begin
 if base/32=to_integer(unsigned(address)) then return data(base mod 32)='1';else return value;end if;end;
 procedure ss_install(signal target:inout std_logic_vector; base:integer; address:std_logic_vector; data:std_logic_vector(31 downto 0)) is begin
 for b in target'range loop if (base+b)/32=to_integer(unsigned(address)) then target(b)<=data((base+b) mod 32);end if;end loop;end;
 procedure ss_install_bool(signal target:inout boolean; base:integer; address:std_logic_vector; data:std_logic_vector(31 downto 0)) is begin
 if base/32=to_integer(unsigned(address)) then target<=data(base mod 32)='1';end if;end;
end package body;
`);
// Every split is constant per slot instance; there is no full-record index mux.
{
 let s=use(read('rtl/vdp_sprite_shifter.vhd'));
 s=s.replace('Port(',`generic(SS_SEQUENTIAL:boolean:=true; SS_OFFSET:integer:=0);\nPort(${ports}`);
 s=s.replace('begin\n ss_sprite_out',"signal ss_local_data:std_logic_vector(31 downto 0);\nbegin\n ss_state_rdata<=ss_local_data;\n"+localRead([ext('shift0','SS_OFFSET'),ext('shift1','SS_OFFSET+8'),ext('shift2','SS_OFFSET+16'),ext('shift3','SS_OFFSET+24'),ext('ss_bool(wideclock)','SS_OFFSET+32')].join('\n'))+'\n ss_sprite_out');
 const first=s.indexOf("if ss_regs_set = '1' then"),last=s.indexOf("elsif ce_pix = '1' then",first);assert(first>0&&last>first);
 const old=s.slice(first,last);
 s=s.slice(0,first)+`if SS_SEQUENTIAL and ss_state_write='1' then\n${[put('shift0','SS_OFFSET'),put('shift1','SS_OFFSET+8'),put('shift2','SS_OFFSET+16'),put('shift3','SS_OFFSET+24'),put('wideclock','SS_OFFSET+32',true)].join('\n')}\nelsif ss_regs_set='1' then\nif not SS_SEQUENTIAL then\n`+old.slice(old.indexOf('\n')+1)+`end if;\n`+s.slice(last);
 write('rtl/vdp_sprite_shifter.vhd',s);
}
{
 let s=use(read('rtl/vdp_sprites.vhd')).replace('generic (','generic ('+generic).replace('port (','port ('+ports);
 s=s.replace('type tcolor is',"type ss_words is array(0 to MAX_SPPL) of std_logic_vector(31 downto 0);\nsignal ss_shifter_data:ss_words;\nsignal ss_local_data:std_logic_vector(31 downto 0);\n type tcolor is");
 s=s.replace('begin\n color',`begin\n process(ss_local_data,ss_shifter_data) variable r:std_logic_vector(31 downto 0);begin r:=ss_local_data;for i in 0 to MAX_SPPL loop r:=r or ss_shifter_data(i);end loop;ss_state_rdata<=r;end process;\n`+localRead(`for i in 0 to MAX_SPPL loop\n${[ext('ss_bool(enable(i))','74*i'),ext('spr_x(i)','74*i+1'),...[0,1,2,3].map(n=>ext('spr_d'+n+'(i)','74*i+'+(9+8*n)))].join('\n')}\nend loop;\n${[ext('data_address','74*(MAX_SPPL+1)'),ext('m2_flags','74*(MAX_SPPL+1)+14'),ext('color_reg','74*(MAX_SPPL+1)+22'),ext("std_logic_vector'(0=>collide_reg)",'74*(MAX_SPPL+1)+26'),ext("std_logic_vector'(0=>overflow_reg)",'74*(MAX_SPPL+1)+27')].join('\n')}`)+'\n color');
 s=s.replace('shifter: entity work.vpd_sprite_shifter\n\t\tport map(',`shifter: entity work.vpd_sprite_shifter\n generic map(SS_SEQUENTIAL=>SS_SEQUENTIAL,SS_OFFSET=>74*i+41)\n port map(ss_state_addr=>ss_state_addr,ss_state_read=>ss_state_read,ss_state_write=>ss_state_write,ss_state_wdata=>ss_state_wdata,ss_state_rdata=>ss_shifter_data(i),`);
 const first=s.indexOf("if ss_regs_set = '1' then"),last=s.indexOf("elsif ce_spload='1' then",first);assert(first>0&&last>first);
 const old=s.slice(first,last);
 s=s.slice(0,first)+`if SS_SEQUENTIAL and ss_state_write='1' then\n${put('data_address','74*(MAX_SPPL+1)')}\n${put('m2_flags','74*(MAX_SPPL+1)+14')}\nif (74*(MAX_SPPL+1)+27)/32=conv_integer(ss_state_addr) then overflow_reg<=ss_state_wdata((74*(MAX_SPPL+1)+27) mod 32);end if;\nfor i in 0 to MAX_SPPL loop\n${[put('enable(i)','74*i',true),put('spr_x(i)','74*i+1'),...[0,1,2,3].map(n=>put('spr_d'+n+'(i)','74*i+'+(9+8*n)))].join('\n')}\nend loop;\nelsif ss_regs_set='1' then\nstate<=WAITING;count<=0;index<=(others=>'0');\nif not SS_SEQUENTIAL then\n`+old.slice(old.indexOf('\n')+1)+`end if;\n`+s.slice(last);
 const second=s.indexOf("if ss_regs_set='1' then",s.indexOf('variable collision')),end=s.indexOf("elsif ce_pix='1' then",second);assert(second>0&&end>second);
 const old2=s.slice(second,end);
 s=s.slice(0,second)+`if SS_SEQUENTIAL and ss_state_write='1' then\n${put('color_reg','74*(MAX_SPPL+1)+22')}\nif (74*(MAX_SPPL+1)+26)/32=conv_integer(ss_state_addr) then collide_reg<=ss_state_wdata((74*(MAX_SPPL+1)+26) mod 32);end if;\nelsif ss_regs_set='1' then\nif not SS_SEQUENTIAL then\n`+old2.slice(old2.indexOf('\n')+1)+`end if;\n`+s.slice(end);
 write('rtl/vdp_sprites.vhd',s);
}
{
 let s=use(read('rtl/vdp_main.vhd')).replace('generic (','generic ('+generic).replace('port (','port ('+ports);
 // Existing source uses tabs/case-insensitive port declarations.
 if(!s.includes('ss_state_addr:'))s=s.replace(/port\s*\(/i,m=>m+ports);
 s=s.replace(/architecture\s+Behavioral\s+of\s+vdp_main\s+is/i,m=>m+'\n signal ss_child_data:std_logic_vector(31 downto 0);');
 s=s.replace(/\bbegin\b/,m=>m+'\n ss_state_rdata<=ss_child_data;');
 s=s.replace(/(vdp_spr_inst:\s*entity work.vdp_sprites\s*generic map\s*\()/,m=>m+'SS_SEQUENTIAL=>SS_SEQUENTIAL,');
 s=s.replace('ss_sprite_out=>ss_sprite_out,',passthrough+'ss_sprite_out=>ss_sprite_out,');
 assert(s.includes('signal ss_child_data'));assert(s.includes('SS_SEQUENTIAL=>SS_SEQUENTIAL'));
 write('rtl/vdp_main.vhd',s);
}
{
 let s=use(read('rtl/vdp.vhd')).replace('generic (','generic ('+generic).replace('port (','port ('+ports);
 s=s.replace('architecture Behavioral of vdp is','architecture Behavioral of vdp is\n signal ss_child_data,ss_local_data:std_logic_vector(31 downto 0);');
 const begin=s.indexOf('\nbegin');assert(begin>0);s=s.slice(0,begin)+s.slice(begin).replace('\nbegin','\nbegin\n ss_state_rdata<=ss_local_data or ss_child_data;\n'+localRead(ext('xspr_collide_shift','74*(MAX_SPPL+1)+28')));
 s=s.replace(/(vdp_main_inst:\s*entity work.vdp_main\s*generic map\s*\()/,m=>m+'SS_SEQUENTIAL=>SS_SEQUENTIAL,');
 s=s.replace('ss_sprite_out=>ss_sprite_out(74*',passthrough+'ss_sprite_out=>ss_sprite_out(74*');
 s=s.replace("if ss_sprite_valid='1' then xspr_collide_shift", "if not SS_SEQUENTIAL then\nif ss_sprite_valid='1' then xspr_collide_shift").replace("else xspr_collide_shift <= (others => '0');end if;","else xspr_collide_shift <= (others => '0');end if;\nend if;");
 // Independent private collision-delay installation wins only while frozen.
 const proc=s.indexOf("\tprocess (clk_sys)\n\tbegin\n\t\tif rising_edge(clk_sys) then\n\t\t\tif ss_regs_set = '1' then\n\t\t\t\tirq_delay");assert(proc>=0);
 const finish=s.indexOf('\n\tend process;',proc),before=s.lastIndexOf('\n\t\tend if;',finish);assert(before>proc);
 s=s.slice(0,before)+`\nif SS_SEQUENTIAL and ss_state_write='1' and ss_freeze='1' then\n${put('xspr_collide_shift','74*(MAX_SPPL+1)+28')}\nend if;\n`+s.slice(before);
 assert(s.includes('SS_SEQUENTIAL=>SS_SEQUENTIAL'));
 if(ROOT_REGISTER)s=s.replace('ss_state_rdata<=ss_local_data or ss_child_data;',`process(clk_sys)begin if rising_edge(clk_sys) then ss_state_rdata<=ss_local_data or ss_child_data;end if;end process;`);
 write('rtl/vdp.vhd',s);
}
console.log('Generated isolated local32 receivers; production unchanged.');
