const fs=require('fs'),p=require('path');const root=p.resolve(__dirname,'../..');
const specs={
 G02:{'rtl/vdp.vhd':['reset_flags']},
 G03:{'rtl/vdp.vhd':['old_RD_n','old_WR_n','old_HL','old_WR_direct','cpu_write_data','data_write','xram_cpu_A_incr']},
 G04:{'rtl/vdp.vhd':['xspr_collide_shift','IRQ_n','last_x0']},
 G05:{'rtl/vdp_background.vhd':['tile_index','x','tile_y','palette','palette_shift','priority_latch','flip_x','datac','data0','data1','data2','data3','shift0','shift1','shift2','shift3','text_shift','text_tile_index','text_pattern','text_phase','text_column','priority','vram_A']},
 G06:{'rtl/vdp_sprites.vhd':['state','count','index','data_address','ce_spload','m2_flags','enable','spr_x','spr_d0','spr_d1','spr_d2','spr_d3','spr_color','spr_active','color','collide','overflow'],'rtl/vdp_sprite_shifter.vhd':['wideclock','shift0','shift1','shift2','shift3']}
};
const inv=[];for(const [g,files]of Object.entries(specs))for(const [file,names]of Object.entries(files)){
 const lines=fs.readFileSync(p.join(root,file),'utf8').split(/\r?\n/);
 for(const name of names){const re=new RegExp('\\b'+name+'\\b','i');
 const sites=[];lines.forEach((line,i)=>{if(re.test(line)&&!line.trim().startsWith('--'))sites.push({line:i+1,text:line,context:lines.slice(Math.max(0,i-3),Math.min(lines.length,i+4)).join('\n')});});
 inv.push({g,file,name,declarations:sites.filter(x=>new RegExp('(?:signal\\s+|^\\s*)'+name+'\\s*:','i').test(x.text)),assignments:sites.filter(x=>new RegExp('\\b'+name+'(?:\\([^;]*?\\))?\\s*<=','i').test(x.text)),all_mentions:sites});
 }
}
fs.writeFileSync(p.join(__dirname,'inventory.json'),JSON.stringify(inv,null,2));
let md='# Exact state sites\n\nGenerated from committed production sources. Every token site and seven-line control context is retained in inventory.json; assignments are lexical VHDL signal assignments. Ports and combinational aliases are included to avoid silently treating them as storage. Array element assignments retain their indices. Read this together with the behavioral classification in review.md.\n\n';
for(const v of inv)md+=`## ${v.g} ${v.file}: ${v.name}\n\nDeclaration: ${v.declarations.map(x=>x.line+': '+x.text.trim()).join('; ')}\n\nAssignments: ${v.assignments.map(x=>x.line).join(', ')}. All declaration/assignment/consumer sites: ${v.all_mentions.map(x=>x.line).join(', ')}.\n\n`;
fs.writeFileSync(p.join(__dirname,'inventory.md'),md);
const bridge={
 'rtl/vdp_main.vhd':['bg_vram_A','bg_color','bg_priority','spr_vram_A','spr_color','line_reset','out_color','cram_A','ss_regs_set'],
 'rtl/vdp.vhd':['spr_collide','spr_overflow','vram_cpu_WE','cram_cpu_WE','cram_vdp_A','cram_vdp_D','vram_vdp_A','vram_vdp_D'],
 'rtl/system.vhd':['vdp_IRQ_n','vdp2_IRQ_n','vdp_RD_n','vdp_WR_n','vdp2_RD_n','vdp2_WR_n','vram_WR','vram2_WR','vdp_color','vdp2_color','vdp_se_bank','vdp2_se_bank'],
 'rtl/video.vhd':['video_state_in','video_state_set','video_state_out','hcount','vcount','vcounter_cpu_reg'],
 'rtl/savestates.sv':['vdp_snap','vdp2_snap','cram_snap','cram2_snap','video_snap','vdp_regs_set','vdp2_regs_set']
};
const connections=[];for(const[file,names]of Object.entries(bridge)){const lines=fs.readFileSync(p.join(root,file),'utf8').split(/\r?\n/);for(const name of names){const re=new RegExp('\\b'+name+'\\b','i'),sites=[];lines.forEach((line,i)=>{if(re.test(line)&&!line.trim().startsWith('--')&&!line.trim().startsWith('//'))sites.push({line:i+1,text:line,context:lines.slice(Math.max(0,i-2),Math.min(lines.length,i+3)).join('\n')});});connections.push({file,name,sites});}}
fs.writeFileSync(p.join(__dirname,'connections.json'),JSON.stringify(connections,null,2));
