const fs=require('fs'),p=require('path'),cp=require('child_process'),assert=require('assert');
const d=__dirname,v=p.join(d,'verification');
const template=fs.readFileSync(p.join(v,'protocol_tb.sv'),'utf8');
for(const [name,rev,words,descriptor]of [['public_v1',null,100,'00640101464d5331'],['baseline','9873761503510e4b2c7e06600bf5515344235c2f',104,'00681101464d5331']]){
 const lib='atomic_'+name;let s=template.slice(0,template.indexOf('initial begin\n for(integer i=0;'));
 assert(s.includes('module protocol_tb;'));s=s.replace('module protocol_tb;','module atomicity_tb;');
 s=s.replace('integer live_writes=0;',`reg drop_response=0;reg[28:0]drop_addr=0;integer vram_writes=0,mapper_writes=0;\nalways @(posedge clk)begin if(vram_WE)vram_writes++;if(mapper_set)mapper_writes++;end\ninteger live_writes=0;`);
 s=s.replace("DDRAM_DOUT<=memory[ra-29'h07c00000];DDRAM_DOUT_READY<=1;","if(!(drop_response&&ra==drop_addr))begin DDRAM_DOUT<=memory[ra-29'h07c00000];DDRAM_DOUT_READY<=1;end ");
 if(words===104)s=s.replaceAll('[99:0]','[103:0]').replaceAll('>=100','>=104').replace(/if\(DDRAM_ADDR>=29'h07c029ca[^;]*\$fatal\(1,"stale (?:read|write)[^;]*;/g,'');
 s+=`
 task reject_all(input integer tag);integer old_live;begin
  old_live=live_writes;operation(0);
  if(live_writes!=old_live)$fatal(1,"FM rejection caused live-state write tag=%0d",tag);
  if(dut.z80_snap[63:0]!==memory[2])$fatal(1,"shadow sentinel did not reach load path");
  $display("PASS ${name} FORMAT_REJECT tag=%0d shadow_changed=yes live_writes=0",tag);
 end endtask
 initial begin
  for(integer i=0;i<12288;i++)memory[i]=0;
  repeat(6)tick;reset_n=1;ready=1;audio_quiescent=1;vblank=1;ss_game_id=32'h12345678;video_state_out=0;
  operation(1);if(memory['h2997]!==64'h${descriptor})$fatal(1,"saved descriptor");
  memory[2]=64'h123456789abcdef0;
  memory['h2997]^=64'h0000010000000000;reject_all(0);memory['h2997]=64'h${descriptor};
  memory['h2998+49][63:32]=32'h80000000;reject_all(1);memory['h2998+49]=0;
  // Fault injection accelerates only the watchdog counter, not a production constant.
  drop_response=1;drop_addr=29'h07c00102;
  fork
   begin
    wait(dut.state==dut.ST_LOAD_VRAM&&dut.dout_expected&&ra==drop_addr&&pending==0);
    @(negedge clk);dut.ddram_watchdog=dut.DDRAM_WATCHDOG_MAX;
   end
   operation(0);
  join
  if(vram_writes!=8||mapper_writes!=0||restores!=0||applies!=0)$fatal(1,"unexpected timeout footprint VRAM=%0d mapper=%0d CPU=%0d FM=%0d",vram_writes,mapper_writes,restores,applies);
  if(ss_freeze!==0)$fatal(1,"timeout did not release freeze");
  $display("PASS ${name} LATE_TIMEOUT partial_restore VRAM_bytes=%0d CPU=%0d FM=%0d",vram_writes,restores,applies);
  $display("PASS ${name} ATOMICITY_AUDIT ALL");$finish;
 end
 initial begin #100000000;$fatal(1,"atomicity TIMEOUT state=%0d",dut.state);end
endmodule
`;
 fs.writeFileSync(p.join(v,'atomicity_'+name+'_tb.sv'),s,{flag:'wx'});
 let src='savestates_sim.sv',snap='opll_snapshot.sv';
 if(rev){src='baseline_savestates_sim.sv';snap='baseline_opll_snapshot.sv';let production=cp.execFileSync('git',['show',rev+':rtl/savestates.sv'],{cwd:p.resolve(d,'../..'),encoding:'utf8'});
  for(const n of ['mapper_snap','evolution_snap','dout_latch']){const re=new RegExp('^reg\\s+\\[[^\\]]+\\]\\s+'+n+';\\r?\\n','m'),m=production.match(re);assert(m);production=production.replace(re,'').replace('// Helpers',m[0]+'// Helpers');}
  fs.writeFileSync(p.join(v,src),production,{flag:'wx'});fs.writeFileSync(p.join(v,snap),cp.execFileSync('git',['show',rev+':rtl/opll_snapshot.sv'],{cwd:p.resolve(d,'../..')}),{flag:'wx'});
 }
 fs.writeFileSync(p.join(v,'atomicity_'+name+'.do'),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib ${lib}\nvlog -sv -quiet -work ${lib} ${snap} ${src} atomicity_${name}_tb.sv\nvsim -t 1ps ${lib}.atomicity_tb\nrun -all\nquit -code 0\n`,{flag:'wx'});
}
console.log('Prepared production-order FM rejection and late-timeout probes for v1 and pinned baseline');
