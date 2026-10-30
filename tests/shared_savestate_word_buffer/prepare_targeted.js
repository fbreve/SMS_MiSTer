const fs=require('fs'),p=require('path'),d=p.resolve(process.argv[2]);
let s=fs.readFileSync(p.join(d,'focused_tb.sv'),'utf8').replace('module focused_tb;','module targeted_tb;').replaceAll('testcase<24','testcase<8').replace('operations!=24','operations!=8');
s=s.replace('reg stalls=0;',`integer prekey=-1,postkey=-1,preleft=0,postleft=0,key;reg dma;integer final_pre[0:127];integer final_post[0:127];
initial for(integer k=0;k<128;k++)begin final_pre[k]=0;final_post[k]=0;end
reg stalls=0;`);
s=s.replace(/DDRAM_BUSY=\(\(a.state==17\)[^;]+;/,`dma=(a.state==17||a.state==18||a.state==35||a.state==45||a.state==52||a.state==53);
 key=operations*1000000+a.state*4096+a.word_cnt;
 DDRAM_BUSY=0;
 if(dma&&((a.state==18?a.wram_byte_cnt:(a.state==35?a.nvram_byte_cnt:a.vram_byte_cnt))==7))begin
 if(!DDRAM_WE_a&&prekey!=key)begin prekey=key;preleft=5;
 if((a.state==18?a.wram_save_addr==(systeme?16383:8191):(a.state==35?a.nvram_save_addr==a.nvram_size_minus_1:a.vram_save_addr[13:0]==16383)))final_pre[a.state]++;
 end
 if(DDRAM_WE_a&&postkey!=key)begin postkey=key;postleft=9;
 if((a.state==18?a.wram_save_addr==(systeme?16383:8191):(a.state==35?a.nvram_save_addr==a.nvram_size_minus_1:a.vram_save_addr[13:0]==16383)))final_post[a.state]++;
 end
 if(preleft>0)begin DDRAM_BUSY=1;preleft--;end
 else if(postleft>0)begin DDRAM_BUSY=1;postleft--;end
 end`);
s=s.replace(' $display("PASS focused',` for(integer k=0;k<128;k++)if(k==17||k==18||k==35||k==45||k==52||k==53)begin
 if(final_pre[k]==0||final_post[k]==0)$fatal(1,"missing final-word stalls state%0d",k);
 $display("FINAL_WORD state=%0d pre=%0d registered=%0d",k,final_pre[k],final_post[k]);end
 $display("PASS targeted`);

fs.writeFileSync(p.join(d,'targeted_tb.sv'),s);
fs.writeFileSync(p.join(d,'targeted.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlog -sv -quiet targeted_tb.sv
vsim -c -t 1ps work.targeted_tb
run -all
quit -code 0
`);
