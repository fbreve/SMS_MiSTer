// Build actual proposed-v15 storage/restart integration from retained final
// investigation fixtures, preserving their ROMs, arguments and future oracle.
const fs=require('fs'),p=require('path'),adapter=require('../savestate_g06_g10_fix/controller_adapter'),rep=require('./background_representation');
const d=__dirname,root=p.resolve(d,'../..');
const families={
 original:{src:p.join(d,'baseline'),cases:['h0','h1']},
 rich:{src:p.join(root,'tests/savestate_g02_g05_v14/rich'),cases:['mode4','gg','text','graphics1','graphics2','mixed_m3','sms224','pal240','scroll']},
 mode_switch:{src:p.join(root,'tests/savestate_g02_g05_v14/mode_switch'),cases:['special'],special:true},
 visible_text:{src:p.join(d,'text_visible_fg'),cases:['early']},
 dead_text_bits:{src:p.join(d,'text_bits_pair'),cases:['h0','h1']},
 g02:{src:p.join(root,'tests/savestate_g02_g05_v14/line_irq'),cases:['active']},
 g03:{src:p.join(root,'tests/savestate_g02_g05_v14/memory_events'),cases:['bus']},
 g04:{src:p.join(root,'tests/savestate_g02_g05_v14/g04_native'),cases:['pending']},
 g06:{src:p.join(root,'tests/savestate_g02_g05_v14/fixture'),cases:['sanity_collision','sanity_overflow']},
 dual_irq:{src:p.join(root,'tests/savestate_g02_g05_v14/dual_irq'),cases:['enabled']},
 dual:{src:p.join(root,'tests/savestate_g02_g05_v14/dual_corrected'),cases:['bus','collision']},
 hl:{src:p.join(root,'tests/savestate_g02_g05_v14/hl'),cases:['edges']}
};
const selected=process.argv.slice(2);if(!selected.length)selected.push(...Object.keys(families));
for(const key of selected){const cfg=families[key];if(!cfg)throw Error('unknown family '+key);const src=cfg.src,dst=p.join(d,'integrated_'+key);fs.mkdirSync(dst,{recursive:true});
 for(const f of ['header.svh','vdp_tb.sv','compile.do','T80_sim.vhd','T80s_sim.vhd'])if(fs.existsSync(p.join(src,f)))fs.copyFileSync(p.join(src,f),p.join(dst,f));
 fs.cpSync(p.join(src,'rtl'),p.join(dst,'rtl'),{recursive:true});
 fs.writeFileSync(p.join(dst,'savestates_sim.sv'),adapter(p.join(d,'proposed/rtl/savestates.sv')));
 const oldBg=fs.existsSync(p.join(src,'rtl/vdp_background.vhd'))?fs.readFileSync(p.join(src,'rtl/vdp_background.vhd'),'utf8'):'';
 let bg=fs.readFileSync(p.join(d,'proposed/rtl/vdp_background.vhd'),'utf8');
 if(oldBg.includes('audit_bg:'))bg=bg.replace(/port\s*\(/i,'port (\n audit_bg: out std_logic_vector(126 downto 0);').replace(/begin\s*\n/,'begin\n audit_bg <= tile_index & x & tile_y & palette & palette_shift & priority_latch & flip_x & datac & data0 & data1 & data2 & data3 & shift0 & shift1 & shift2 & shift3 & text_shift & text_tile_index & text_pattern & text_phase & text_column;\n');
 if(oldBg.includes('audit_extra:'))bg=bg.replace(/port\s*\(/i,'port (\n audit_extra: out std_logic_vector(15 downto 0);').replace(/begin\s*\n/,'begin\n audit_extra <= bg_vram_address & bg_priority & ce_pix;\n');
 fs.writeFileSync(p.join(dst,'rtl/vdp_background.vhd'),bg);
 const ports=`ss_bg_out: out std_logic_vector(138 downto 0);\n ss_bg_in: in std_logic_vector(138 downto 0) := (others=>'0');\n ss_bg_valid: in std_logic := '0';\n `;
 for(const f of ['vdp_main.vhd','vdp.vhd']){let s=fs.readFileSync(p.join(dst,'rtl',f),'utf8');if(!s.includes('ss_bg_out:')){
  s=s.replace('ss_sprite_out: out',ports+'ss_sprite_out: out');
  if(f==='vdp_main.vhd')s=s.replace(/(ss_restore\s*=>\s*ss_regs_set,)/,'ss_bg_out=>ss_bg_out,ss_bg_in=>ss_bg_in,ss_bg_valid=>ss_bg_valid,\n        $1');
  else s=s.replace('ss_sprite_out=>ss_sprite_out(','ss_bg_out=>ss_bg_out,ss_bg_in=>ss_bg_in,ss_bg_valid=>ss_bg_valid,\n        ss_sprite_out=>ss_sprite_out(');
 }fs.writeFileSync(p.join(dst,'rtl',f),s);}
 let h=fs.readFileSync(p.join(dst,'header.svh'),'utf8');h=h.replace('savestates dut(',`wire[138:0]candidate_bg_live,candidate_bg2_live,candidate_bg_in,candidate_bg2_in;wire candidate_bg_valid;
savestates dut(.bg_out(candidate_bg_live),.bg2_out(candidate_bg2_live),.bg_in(candidate_bg_in),.bg2_in(candidate_bg2_in),.bg_valid(candidate_bg_valid),`);fs.writeFileSync(p.join(dst,'header.svh'),h);
 let t=fs.readFileSync(p.join(dst,'vdp_tb.sv'),'utf8'),dual=/\bvdp2\s*\(/.test(t);
 if(t.includes('.ss_bg_out(prototype_live)')){
  t=t.replace(/wire\[138:0\]prototype_live;[\s\S]*?wire\[15:0\]bg_extra;/,'wire[15:0]bg_extra;');
  t=t.replace('.ss_bg_out(prototype_live)','.ss_bg_out(candidate_bg_live)').replace('.ss_bg_in(prototype_apply)','.ss_bg_in(candidate_bg_in)').replace('.ss_bg_valid(!warming)','.ss_bg_valid(candidate_bg_valid)');
 }else t=t.replace(/\bvdp1\s*\(/,'vdp1(.ss_bg_out(candidate_bg_live),.ss_bg_in(candidate_bg_in),.ss_bg_valid(candidate_bg_valid),');
 if(dual)t=t.replace(/\bvdp2\s*\(/,'vdp2(.ss_bg_out(candidate_bg2_live),.ss_bg_in(candidate_bg2_in),.ss_bg_valid(candidate_bg_valid),');
 else t=t.replace(/\nendmodule\s*$/,'\nassign candidate_bg2_live=0;\nendmodule\n');
 // The original characterizer counted failures. Actual fix runs require zero.
 t=t.replace('if(pixel_divs)$display("CONFIRMED_G05 naturally accepted text-to-Mode4 visible divergence pass%0d",pass);','if(pixel_divs||fetch_divs)$fatal(1,"original G05 corruption remains");');
 t=t.replace('if(pixel_divs)$display("CONFIRMED_G05 visiblePixels%0d pass%0d",pixel_divs,pass);','if(pixel_divs)$fatal(1,"deferred mode-switch pixel corruption remains");');
 t=t.replace('if(PROTOTYPE_OMIT==0&&(pixel_divs||fetch_divs))$fatal(1,"proposed representation insufficient");','if(pixel_divs||fetch_divs)$fatal(1,"actual v15 replay differs");').replace('if(PROTOTYPE_OMIT!=0&&!pixel_divs)$fatal(1,"causal omission control did not diverge");','');
 t=t.replace('$display("PASS PROTOTYPE139 omit%0d",PROTOTYPE_OMIT);','$display("PASS ACTUAL V15 BACKGROUND");');
 if(t.includes('prototype_apply')||t.includes('prototype_snap'))throw Error('prototype side-record feedback retained '+key);
 // Registered VBlank can be stale after a viewport change. Require exact
 // color/fetch/priority at ALL sampled pixels, a superset of visible pixels.
 t=t.replaceAll('!vb&&x>0&&x<=256&&','').replaceAll('y<192&&x>0&&x<=256&&','').replaceAll('((y<((GG)?168:192)&&x<256)&&color!==pixels[j])','(color!==pixels[j])');
 t=t.replaceAll('V14 VDP','V15 VDP');
 t=t.replace(/\nendmodule\s*$/,`
reg[138:0]bg_capture,bg2_capture,bg_hold,bg2_hold;reg bg_was_frozen=0;integer bg_settle=0;
always@(posedge ss_freeze)if(dut.do_save)begin #0.001;bg_capture=candidate_bg_live;bg2_capture=candidate_bg2_live;
 if(!warming&&$isunknown({candidate_bg_live,candidate_bg2_live}))$fatal(1,"unknown accepted background payload");
 $display("CAPTURE_BG139 primary%h secondary%h",bg_capture,bg2_capture);
end
always@(posedge clk)begin
 if(vdp_regs_set||vdp2_regs_set)bg_settle=3;
 if(bg_settle>0)bg_settle--;
 if(frozen&&bg_was_frozen&&bg_settle==0)begin #0.001;
  if(candidate_bg_live!==bg_hold||candidate_bg2_live!==bg2_hold)$fatal(1,"background advanced while frozen");
 end
 #0.002;bg_hold=candidate_bg_live;bg2_hold=candidate_bg2_live;bg_was_frozen=frozen;
end
reg[138:0]prepare_bg,prepare_bg2;
always@(posedge cpu_prepare)begin prepare_bg=candidate_bg_live;prepare_bg2=candidate_bg2_live;end
always@(posedge clk)if(cpu_prepare&&(candidate_bg_live!==prepare_bg||candidate_bg2_live!==prepare_bg2))$fatal(1,"CPU preparation advanced background");
endmodule
`);fs.writeFileSync(p.join(dst,'vdp_tb.sv'),t);
 let c=fs.readFileSync(p.join(dst,'compile.do'),'utf8').replace('../../../rtl/vdp_background.vhd','rtl/vdp_background.vhd');fs.writeFileSync(p.join(dst,'compile.do'),c);
 for(const id of cfg.cases)for(const ref of [true,false]){const from=p.join(src,cfg.special?'reference':(ref?'reference_':'dut_')+id),to=p.join(dst,(ref?'reference_':'dut_')+id);fs.mkdirSync(to,{recursive:true});for(const f of ['run.do','rom.hex']){
  let content=fs.readFileSync(p.join(from,f),'utf8');if(cfg.special&&f==='run.do'&&!ref)content=content.replace('-gREFERENCE=1','-gREFERENCE=0');fs.writeFileSync(p.join(to,f),content);
 }}
 fs.writeFileSync(p.join(dst,'origin.json'),JSON.stringify({key,src,cases:cfg.cases,productionInputs:'proposed/',stage:'actual v15; normalized proposed sources match production'},null,2));
 console.log('Prepared actual-storage integrated_'+key);
}
