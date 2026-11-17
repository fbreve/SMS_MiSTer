const fs=require('fs'),d=__dirname;
const v=fs.readFileSync('rtl/mapper_detect.vhd','utf8');
const ports=[...v.slice(v.indexOf('port ('),v.indexOf('end mapper_detect')).matchAll(/(\w+)\s*:\s*(in|out)\s+(std_logic_vector\((\d+) downto 0\)|std_logic)/gi)];
const named={clk_sys:'clk_sys',ROMCL:'clk_sys',ROMAD:'ioctl_addr',ROMDT:'ioctl_dout',ROMEN:'ioctl_wr',RESET_n:"1'b1",rom_crc32_o:'crc'};
let inst='mapper_detect detector('+ports.map(p=>'.'+p[1]+'('+(named[p[1]]??(p[2].toLowerCase()==='out'?'':p[4]?(+p[4]+1)+"'d0":"1'b0"))+')').join(',')+');';
let sms=fs.readFileSync('SMS.sv','utf8');let sig=sms.slice(sms.indexOf('reg [31:0] ss_game_id'),sms.indexOf('// BIOS mode:'));
for(const name of ['a','b'])fs.writeFileSync(d+'/identity_'+name+'.hex',[...fs.readFileSync(d+'/identity_'+name+'.bin')].map(b=>b.toString(16).padStart(2,'0')).join('\n'));
fs.writeFileSync(d+'/identity_tb.sv',`\`timescale 1ns/1ps
module identity_tb;
reg clk_sys=0;always #5 clk_sys=~clk_sys;
reg cart_download=0,ioctl_wr=0;reg[24:0]ioctl_addr=0;reg[7:0]ioctl_dout=0;wire[31:0]crc;
${sig}\n${inst}
reg[7:0]a[0:32767],b[0:32767];reg[31:0]first_crc,first_sig;
task tick;begin @(negedge clk_sys);#1;end endtask
initial begin
 $readmemh("identity_a.hex",a);$readmemh("identity_b.hex",b);
 repeat(3)tick;
 for(integer pass=0;pass<2;pass++)begin
  cart_download=1;tick;ioctl_wr=1;
  for(integer j=0;j<32768;j++)begin ioctl_addr=j;ioctl_dout=pass?b[j]:a[j];tick;end
  ioctl_wr=0;cart_download=0;repeat(3)tick;
  if(pass==0)begin first_crc=crc;first_sig=ss_game_id;end
  else if(crc!==first_crc||ss_game_id!==first_sig)$fatal(1,"identity collision not reproduced");
 end
 if((crc^32'hffffffff)!==32'h703ab279||ss_game_id!==32'h811c9dc5)$fatal(1,"signature model mismatch");
 $display("PASS ACTUAL RTL IDENTITIES COLLIDE crc=%h rolling=%h",crc^32'hffffffff,ss_game_id);$finish;
end
endmodule
`);
fs.writeFileSync(d+'/identity.do','onerror {quit -code 1}\nvcom -2008 -quiet ../../rtl/mapper_detect.vhd\nvlog -sv -quiet identity_tb.sv\nvsim -c -t 1ps work.identity_tb\nset NumericStdNoWarnings 1\nrun -all\nquit -code 0\n');
