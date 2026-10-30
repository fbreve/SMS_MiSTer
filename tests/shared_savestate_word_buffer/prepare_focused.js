const fs=require('fs'),p=require('path'),d=p.resolve(process.argv[2]);
let s=fs.readFileSync(p.join(d,'directed_tb.sv'),'utf8').replace('module directed_tb;','module focused_tb;');
s=s.replace('mapper_out=systeme?((testcase/2)%4)*64\'h40:64\'h1000000000000;',`mapper_out=systeme?((testcase/2)%4)*64'h40:((testcase/2)%4==0?0:((testcase/2)%4==1?64'h1000000000000:((testcase/2)%4==2?64'h4000000000000:64'h8000000000000)));`);
s=s.replace('operation(0);','/* save-only directed matrix */').replace(/if\(loads!=testcase\+1\)[^;]*;/,'').replace('loads!=24||operations!=48','loads!=0||operations!=24');
s=s.replace('||reads<1000','').replace('DDRAM_BUSY=(cycles%41<13)||(cycles%137<23);','DDRAM_BUSY=((a.state==17)||(a.state==18)||(a.state==35)||(a.state==45)||(a.state==52)||(a.state==53)) && ((cycles%41<13)||(cycles%137<23));');
s=s.replace('reg stalls=0;',`reg stalls=0;integer held=0,pre7=0,transitions=0;reg[6:0]previous_state;integer seen[0:127];integer accepted[0:127];integer busy7[0:127];integer registered7[0:127];
 initial for(integer k=0;k<128;k++)begin seen[k]=0;accepted[k]=0;busy7[k]=0;registered7[k]=0;end`);
s=s.replace(' DDRAM_DOUT_READY<=0;',` if(reset_n)begin
 seen[a.state]++;if(a.state!==previous_state)transitions++;previous_state=a.state;
 if(DDRAM_WE_a&&DDRAM_BUSY)begin held++;registered7[a.state]++;end
 if(DDRAM_WE_a&&!DDRAM_BUSY)accepted[a.state]++;
 if(DDRAM_BUSY&&((a.vram_byte_cnt==7)||(a.wram_byte_cnt==7)||(a.nvram_byte_cnt==7)))begin pre7++;busy7[a.state]++;end
 end
 DDRAM_DOUT_READY<=0;`);
s=s.replace(' $display("PASS directed accepted_data_address_equivalence");',` for(integer k=0;k<128;k++)if(accepted[k])$display("COVER state=%0d accepted=%0d busy_at_7=%0d held=%0d",k,accepted[k],busy7[k],registered7[k]);
 if(held==0||pre7==0||transitions<100)$fatal(1,"missing risk coverage");
 $display("PASS focused held=%0d busy7=%0d transitions=%0d",held,pre7,transitions);`);
fs.writeFileSync(p.join(d,'focused_tb.sv'),s);
fs.writeFileSync(p.join(d,'focused.do'),`onerror {quit -code 1}
onbreak {quit -code 1}
vlog -sv -quiet focused_tb.sv
vsim -c -t 1ps work.focused_tb
run -all
quit -code 0
`);
