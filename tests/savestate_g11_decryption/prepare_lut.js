const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto'),d=__dirname,root=p.resolve(d,'../..');
if(cp.execFileSync('git',['diff','--name-only'],{cwd:root,encoding:'utf8'}).trim())throw Error('Investigation requires unchanged production');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const files=cp.execFileSync('git',['ls-files'],{cwd:root,encoding:'utf8'}).trim().split(/\r?\n/).filter(f=>fs.statSync(p.join(root,f)).isFile());
fs.writeFileSync(p.join(d,'baseline.json'),JSON.stringify({head:cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),files:Object.fromEntries(files.map(f=>[f,sha(fs.readFileSync(p.join(root,f)))]))},null,2));
fs.writeFileSync(p.join(d,'lut_tb.sv'),`module lut_tb;
reg clk=0,m1=0;reg[7:0]raw=0,key=0;wire[7:0]out;wire[12:0]ka;
MC8123_rom_decrypt dut(clk,m1,16'd0,out,raw,ka,key);
integer fd;initial begin fd=$fopen("mc_forward.hex","w");
for(integer op=0;op<2;op++)for(integer k=0;k<256;k++)for(integer v=0;v<256;v++)begin
 m1=op;key=k;raw=v;#2;clk=1;#1;if($isunknown(out))$fatal(1,"unknown decrypt");$fdisplay(fd,"%02h",out);clk=0;#1;
end
$fclose(fd);$display("PASS LUT entries131072");$finish;end
endmodule\n`);
fs.writeFileSync(p.join(d,'lut.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib lut_work\nvlog -work lut_work -sv -quiet ../../rtl/MC8123.v lut_tb.sv\nvsim -c lut_work.lut_tb\nrun -all\nquit -code 0\n`);

