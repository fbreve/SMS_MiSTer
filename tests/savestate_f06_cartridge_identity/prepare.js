const fs=require('fs'),cp=require('child_process'),crypto=require('crypto'),d=__dirname;
const read=p=>fs.readFileSync(p,'utf8').replace(/\r\n/g,'\n');
const hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
if(!fs.existsSync(d+'/baseline.json')){
 const files=cp.execFileSync('git',['ls-files'],{encoding:'utf8'}).trim().split('\n').filter(p=>fs.existsSync(p)&&fs.statSync(p).isFile());
 fs.writeFileSync(d+'/baseline.json',JSON.stringify({head:cp.execFileSync('git',['rev-parse','HEAD'],{encoding:'utf8'}).trim(),files:Object.fromEntries(files.map(p=>[p,hash(p)])),prerequisites:Object.fromEntries(['tests/savestate_f06_sega_sram/review.md','tests/savestate_coverage/review.md'].map(p=>[p,hash(p)]))},null,2));
}
const src=read('sys/hps_io.sv');let body=src.slice(src.indexOf('localparam FIO_FILE_TX'),src.indexOf('endmodule'));
fs.writeFileSync(d+'/fio_decoder.sv',`// Production FIO block extracted verbatim; unrelated video/PS2 not instantiated.
module fio_decoder(input clk_sys,inout[45:0]HPS_BUS,output reg ioctl_download=0,
 output reg[15:0]ioctl_index,output reg ioctl_wr,output reg[26:0]ioctl_addr,
 output reg[7:0]ioctl_dout,output reg[31:0]ioctl_file_ext);
localparam WIDE=0,DW=7;
wire fp_enable=HPS_BUS[35],io_strobe=HPS_BUS[33];wire[15:0]io_din=HPS_BUS[31:16];
reg ioctl_upload=0,ioctl_rd;wire[7:0]ioctl_din=0;
${body}\nendmodule\n`);
let tb=read(d+'/interface_tb.sv');const start=tb.indexOf('hps_io #('),end=tb.indexOf('));',start)+3;
tb=tb.slice(0,start)+`fio_decoder dut(.clk_sys(clk),.HPS_BUS(bus),.ioctl_download(downloading),.ioctl_index(index),.ioctl_addr(addr),.ioctl_dout(data),.ioctl_wr(wr),.ioctl_file_ext(extension));`+tb.slice(end);
tb=tb.replace(/  if\(size!==0\|\|readonly!==0\).*?\n/,'');
fs.writeFileSync(d+'/fio_tb.sv',tb);
fs.writeFileSync(d+'/interface.do','onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib interface_work\nvlog -sv -suppress 2244 -quiet -work interface_work fio_decoder.sv fio_tb.sv\nvsim -c -t 1ps interface_work.interface_tb\nrun -all\nquit -code 0\n');
console.log('Prepared unchanged FIO decoder component');
