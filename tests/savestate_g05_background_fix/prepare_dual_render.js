const fs=require('fs'),p=require('path'),d=__dirname,src=p.join(d,'integrated_dual'),dst=p.join(d,'integrated_dual_render');fs.mkdirSync(dst,{recursive:true});
for(const f of ['header.svh','vdp_tb.sv','compile.do','T80_sim.vhd','T80s_sim.vhd','savestates_sim.sv'])fs.copyFileSync(p.join(src,f),p.join(dst,f));fs.cpSync(p.join(src,'rtl'),p.join(dst,'rtl'),{recursive:true});
let main=fs.readFileSync(p.join(dst,'rtl/vdp_main.vhd'),'utf8');main=main.replace(/port\s*\(/i,'port (\n audit_main_probe: out std_logic_vector(19 downto 0);').replace(/begin\s*\n/,'begin\n audit_main_probe <= bg_color & bg_priority & bg_vram_A;\n');fs.writeFileSync(p.join(dst,'rtl/vdp_main.vhd'),main);
let top=fs.readFileSync(p.join(dst,'rtl/vdp.vhd'),'utf8');top=top.replace('architecture Behavioral of vdp is','architecture Behavioral of vdp is\n signal audit_main_probe: std_logic_vector(19 downto 0);').replace("(63 downto 32 => '0')",'audit_main_probe & cram_vdp_A & "0000000"').replace(/(vdp_main_inst: entity work\.vdp_main[\s\S]*?port map\s*\()/,'$1\n audit_main_probe => audit_main_probe,');fs.writeFileSync(p.join(dst,'rtl/vdp.vhd'),top);
let t=fs.readFileSync(p.join(dst,'vdp_tb.sv'),'utf8');
t=t.replace("if(n>=14'h3800&&n<14'h3f00)pattern=n[0]?8'h08:8'h01;","if(n>=14'h3800&&n<14'h3f00)pattern=n[0]?((n>>3)&31):((n>>1)*13)^(n>>5);");
t=t.replace(" if(n>=14'h2000&&n<14'h2040)pattern=n[1:0]==0?8'hff:8'h00;",'');
t=t.replace(" pattern2=pattern(n)^8'h5a;"," pattern2=pattern(n)^8'h5a;\n if(n>=14'h3f00&&n<14'h3f40)pattern2=208;");
t=t.replace('  savechecks++;','  if(!REFERENCE&&(audit[63:32]!==audit_trace[j][63:32]||audit2[63:32]!==second_audit[j][63:32]))$fatal(1,"dual SAVE background fetch/palette/priority mismatch");\n  savechecks++;');
t=t.replace('   checks++;','   if(audit[63:32]!==audit_trace[j][63:32]||audit2[63:32]!==second_audit[j][63:32])$fatal(1,"dual LOAD background fetch/palette/priority mismatch");\n   checks++;');
fs.writeFileSync(p.join(dst,'vdp_tb.sv'),t);
const sourceRom=fs.readFileSync(p.join(src,'reference_collision/rom.hex'),'utf8').trim().split(/\s+/).map(x=>parseInt(x,16));
for(const [id,pEnabled,sEnabled]of [['primary',true,false],['secondary',false,true],['both',true,true]]){let rom=[...sourceRom];
 for(const[port,enabled]of [[0xbb,sEnabled],[0xbf,pEnabled]]){let found=false;for(let i=0;i<600;i++)if(rom[i]===0x3e&&rom[i+2]===0xd3&&rom[i+3]===port&&rom[i+4]===0x3e&&rom[i+5]===0x81){rom[i+1]=enabled?0x40:0;found=true;break;}if(!found)throw Error('display register '+port);}
 for(const ref of [1,0]){const dir=p.join(dst,(ref?'reference_':'dut_')+id);fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(p.join(dir,'rom.hex'),rom.map(x=>x.toString(16).padStart(2,'0')).join('\n')+'\n');let run=fs.readFileSync(p.join(src,(ref?'reference_':'dut_')+'collision/run.do'),'utf8').replace('-gREPLAYS=3','-gSPRITES=0 -gSAMPLES=42000 -gREPLAYS=3').replace('-gCOLLISION_CASE=1','-gCOLLISION_CASE=0');fs.writeFileSync(p.join(dir,'run.do'),run);}
}
