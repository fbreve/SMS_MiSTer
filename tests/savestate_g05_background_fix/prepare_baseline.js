// Fresh reproduction; preserve every historical investigation artifact.
const fs=require('fs'),p=require('path'),cp=require('child_process'),crypto=require('crypto');
const d=__dirname,root=p.resolve(d,'../..'),src=p.join(root,'tests/savestate_g02_g05_v14/text_history'),dst=p.join(d,'baseline');
fs.mkdirSync(dst,{recursive:true});
for(const f of ['header.svh','vdp_tb.sv','compile.do','T80_sim.vhd','T80s_sim.vhd','savestates_sim.sv'])fs.copyFileSync(p.join(src,f),p.join(dst,f));
fs.cpSync(p.join(src,'rtl'),p.join(dst,'rtl'),{recursive:true});
// Additional observation only: registered fetch address, priority and CE.
let bg=fs.readFileSync(p.join(dst,'rtl/vdp_background.vhd'),'utf8').replace(' audit_bg: out',' audit_extra: out std_logic_vector(15 downto 0);\n audit_bg: out').replace(' audit_bg <=',' audit_extra <= vram_A & priority & ce_pix;\n audit_bg <=');
fs.writeFileSync(p.join(dst,'rtl/vdp_background.vhd'),bg);
for(const f of ['vdp_main.vhd','vdp.vhd']){let s=fs.readFileSync(p.join(dst,'rtl',f),'utf8').replace(' audit_bg: out',' audit_extra: out std_logic_vector(15 downto 0);\n audit_bg: out').replace(' audit_bg => audit_bg,',' audit_extra => audit_extra,\n audit_bg => audit_bg,');fs.writeFileSync(p.join(dst,'rtl',f),s);}
let s=fs.readFileSync(p.join(dst,'vdp_tb.sv'),'utf8').replace('wire[126:0]bg_state;','wire[15:0]bg_extra;wire[126:0]bg_state;').replace('.audit_bg(bg_state),','.audit_extra(bg_extra),.audit_bg(bg_state),');
s=s.replace(' BG%h",x,y,vdp_regs,probe,bg_state',' BG%h EXTRA%h RGB%h CE%b%b",x,y,vdp_regs,probe,bg_state,bg_extra,color,ce_vdp,ce_pix');
s=s.replace(/\nendmodule\s*$/,`
always@(posedge clk)if(!setup&&!frozen&&ce_pix&&y==0&&x>=18&&x<=45)begin #1;
 $display("CAUSAL_PIXEL history%0d xy%0d,%0d M4%b RGB%h BG%h EXTRA%h",HISTORY,x,y,vdp_regs[5],color,bg_state,bg_extra);
end
endmodule
`);fs.writeFileSync(p.join(dst,'vdp_tb.sv'),s);
for(const name of ['reference_h0','reference_h1','dut_h0','dut_h1']){fs.mkdirSync(p.join(dst,name),{recursive:true});for(const f of ['run.do','rom.hex'])fs.copyFileSync(p.join(src,name,f),p.join(dst,name,f));}
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),files={};
for(const f of cp.execFileSync('git',['ls-files'],{cwd:root}).toString().trim().split(/\r?\n/))if(fs.statSync(p.join(root,f)).isFile())files[f]=sha(fs.readFileSync(p.join(root,f)));
fs.writeFileSync(p.join(d,'baseline.json'),JSON.stringify({head:cp.execFileSync('git',['rev-parse','HEAD'],{cwd:root}).toString().trim(),branch:cp.execFileSync('git',['branch','--show-current'],{cwd:root}).toString().trim(),files},null,2));
fs.writeFileSync(p.join(d,'.gitignore'),'/baseline/vdp_work/\n/**/vdp_work/\n/**/work/\n/**/modelsim.ini\n/**/*.wlf\n/**/transcript\n/**/stdout.log\n/candidate/\n/quartus_baseline/\n');
console.log('Prepared fresh unmodified-v14 original witness with read-only expanded observations');
