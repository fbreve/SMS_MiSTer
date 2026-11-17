const fs=require('fs'),p=require('path'),cp=require('child_process');const d=__dirname,kind=process.argv[2]||'combined';
cp.execFileSync(process.execPath,[p.join(d,'propose.js')],{stdio:'inherit'});
cp.execFileSync(process.execPath,[p.join(d,'prepare_matrix.js'),kind],{stdio:'inherit'});
const dst=p.join(d,kind),adapter=require('../savestate_g06_g10_fix/controller_adapter');
fs.writeFileSync(p.join(dst,'savestates_sim.sv'),adapter(p.join(d,'proposed/savestates.sv')));
fs.copyFileSync(p.join(d,'proposed/jt89.v'),p.join(dst,'jt89.v'));
let s=fs.readFileSync(p.join(dst,'audio_tb.sv'),'utf8');
s=s.replace('savestates dut(',"wire audio_pending_tick;\nsavestates dut(.audio_pending_tick(audio_pending_tick),");
s=s.replace('jt89 psg1(', 'jt89 psg1(.ss_pending_tick(audio_pending_tick),').replace('jt89 psg2(', 'jt89 psg2(.ss_pending_tick(audio_pending_tick && systeme),').replace('jt89 rpsg(',"jt89 rpsg(.ss_pending_tick(1'b0),").replace('jt89 rpsg2(',"jt89 rpsg2(.ss_pending_tick(1'b0),");
s=s.replace(/\nendmodule\s*$/,`
integer pending_replays=0;
always@(posedge ss_freeze)pending_replays=0;
always@(negedge clk)if(audio_pending_tick)begin
 pending_replays++;
 if(pending_replays>1||ss_freeze||cpu_prepare||audio_ext_set)$fatal(1,"pending event replayed outside single guest release edge");
 $display("PENDING_REPLAY cycle%0d savedPhase%0d savedDiv%0d active%b",cycle,dut.phase_snap,dut.audio_div_snap,dut.capture_tick_snap);
end
endmodule
`);
fs.writeFileSync(p.join(dst,'audio_tb.sv'),s);
s=fs.readFileSync(p.join(dst,'compile.do'),'utf8').replace('../../../rtl/jt89/jt89.v','jt89.v');fs.writeFileSync(p.join(dst,'compile.do'),s);
console.log('Prepared coupled prototype '+kind);
