const fs=require('fs');const d=__dirname;
let v=fs.readFileSync('rtl/mapper_ctrl.vhd','utf8');let ports=[...v.slice(v.indexOf('port ('),v.indexOf('end entity')).matchAll(/(\w+)\s*:\s*(in|out)\s+(std_logic_vector\((\d+) downto 0\)|std_logic)/gi)];
const named={RESET_n:'mapper_reset_n',clk_sys:'clk',mapper_set:'mapper_set',mapper_in:'mapper_in',bootloader_n:"1'b1",ce_z80:"1'b1",WR_n:'wr',MREQ_n:'mreq',A:'a',ss_freeze:'ss_freeze',D_in:'di',bank0_out:'b0',bank1_out:'b1',bank2_out:'b2',bank3_out:'b3',nvram_e_out:'en',nvram_ex_out:'ext',nvram_p_out:'bank',nvram_cme_out:'cme',pak4_reg2_out:'pak',nem_bank0_out:'nem'};
let inst='mapper_ctrl mapper('+ports.map(p=>'.'+p[1]+'('+(named[p[1]]??(p[2].toLowerCase()==='out'?'':p[4]?(+p[4]+1)+"'d0":"1'b0"))+')').join(',')+');';
fs.writeFileSync(d+'/sram_tb.sv',fs.readFileSync(d+'/prefix.sv','utf8')+fs.readFileSync(d+'/tail.sv','utf8').replace('__MAPPER__',inst));
