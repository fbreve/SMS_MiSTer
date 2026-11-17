const fs=require('fs'),p=require('path'),rep=require('./background_representation');
const d=__dirname,src=p.join(d,'baseline'),dst=p.join(d,'prototype');fs.mkdirSync(dst,{recursive:true});
for(const f of ['header.svh','vdp_tb.sv','compile.do','T80_sim.vhd','T80s_sim.vhd','savestates_sim.sv'])fs.copyFileSync(p.join(src,f),p.join(dst,f));
fs.cpSync(p.join(src,'rtl'),p.join(dst,'rtl'),{recursive:true});
fs.writeFileSync(p.join(dst,'rtl/vdp_background.vhd'),rep.proposal(fs.readFileSync(p.join(src,'rtl/vdp_background.vhd'),'utf8')));
const ports=` ss_bg_out: out std_logic_vector(138 downto 0);
 ss_bg_in: in std_logic_vector(138 downto 0) := (others=>'0');
 ss_bg_valid: in std_logic := '0';\n`;
for(const f of ['vdp_main.vhd','vdp.vhd']){let s=fs.readFileSync(p.join(dst,'rtl',f),'utf8').replace(/port\s*\(/i,'port (\n'+ports).replace(' audit_bg => audit_bg,',' ss_bg_out=>ss_bg_out,ss_bg_in=>ss_bg_in,ss_bg_valid=>ss_bg_valid,\n audit_bg => audit_bg,');fs.writeFileSync(p.join(dst,'rtl',f),s);}
let h=fs.readFileSync(p.join(dst,'header.svh'),'utf8').replace('HISTORY=0;','HISTORY=0,PROTOTYPE_OMIT=0;');fs.writeFileSync(p.join(dst,'header.svh'),h);
let t=fs.readFileSync(p.join(dst,'vdp_tb.sv'),'utf8');
t=t.replace('wire[15:0]bg_extra;',`wire[138:0]prototype_live;reg[138:0]prototype_snap=0;reg[138:0]prototype_apply;
always@* begin prototype_apply=prototype_snap;
 if(PROTOTYPE_OMIT==1)prototype_apply[${rep.fields.find(f=>f[0]==='shift0')[2]}:${rep.fields.find(f=>f[0]==='shift3')[3]}]=0;
 if(PROTOTYPE_OMIT==2)prototype_apply[${rep.fields.find(f=>f[0]==='data0')[2]}:${rep.fields.find(f=>f[0]==='data3')[3]}]=0;
 if(PROTOTYPE_OMIT==3)begin
  prototype_apply[${rep.fields.find(f=>f[0]==='text_shift')[2]}:${rep.fields.find(f=>f[0]==='text_shift')[3]}]=0;
  prototype_apply[${rep.fields.find(f=>f[0]==='text_pattern_hi')[2]}:${rep.fields.find(f=>f[0]==='text_pattern_hi')[3]}]=0;
 end
end
always@(posedge ss_freeze)if(dut.do_save&&!warming)begin #0.001;
 if($isunknown(prototype_live))$fatal(1,"unknown proposed background snapshot");
 prototype_snap=prototype_live;$display("PROTOTYPE139_CAPTURE %h",prototype_snap);
end
wire[15:0]bg_extra;`);
t=t.replace('.audit_extra(bg_extra),','.ss_bg_out(prototype_live),.ss_bg_in(prototype_apply),.ss_bg_valid(!warming),.audit_extra(bg_extra),');
t=t.replace('if(pixel_divs)$display("CONFIRMED_G05 naturally accepted text-to-Mode4 visible divergence pass%0d",pass);','if(PROTOTYPE_OMIT==0&&(pixel_divs||fetch_divs))$fatal(1,"proposed representation insufficient");\n  if(PROTOTYPE_OMIT!=0&&!pixel_divs)$fatal(1,"causal omission control did not diverge");');
t=t.replace('$display("PASS RICH V14 VDP', '$display("PASS PROTOTYPE139 omit%0d",PROTOTYPE_OMIT);\n $display("PASS RICH V14 VDP');
fs.writeFileSync(p.join(dst,'vdp_tb.sv'),t);
for(const hist of [0,1]){const name='dut_h'+hist,dir=p.join(dst,name);fs.mkdirSync(dir,{recursive:true});for(const f of ['rom.hex','run.do'])fs.copyFileSync(p.join(src,name,f),p.join(dir,f));}
for(const omit of [1,2]){const dir=p.join(dst,'dut_omit'+omit);fs.mkdirSync(dir,{recursive:true});fs.copyFileSync(p.join(src,'dut_h0/rom.hex'),p.join(dir,'rom.hex'));fs.writeFileSync(p.join(dir,'run.do'),fs.readFileSync(p.join(src,'dut_h0/run.do'),'utf8').replace('-gSAMPLES=42000','-gSAMPLES=25000').replace('-gREPLAYS=3','-gREPLAYS=1 -gPROTOTYPE_OMIT='+omit));}
fs.writeFileSync(p.join(d,'proposed_fields.json'),JSON.stringify({width:rep.width,fields:rep.fields},null,2));
console.log('Prepared explicit139-bit side-record prototype; production/controller still v14 unchanged');
