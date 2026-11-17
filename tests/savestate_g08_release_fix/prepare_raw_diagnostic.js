const fs=require('fs'),p=require('path'),cp=require('child_process');const d=__dirname;
cp.execFileSync(process.execPath,[p.join(d,'prepare_matrix.js'),'raw_characterization'],{stdio:'inherit'});
const dir=p.join(d,'raw_characterization'),file=p.join(dir,'audio_tb.sv');let s=fs.readFileSync(file,'utf8');
s=s.replace('if(raw!==raw_oracle[k])$fatal(1,"raw PSG/div mismatch', 'if(raw!==raw_oracle[k])$display("EXPECTED_RAW_CAPTURE_DIFFERENCE');
s=s.replace('if({al,ar}!==oracle[k]||audio_phase_out!==phase_oracle[k])$fatal(1,"audio mismatch', 'if({al,ar}!==oracle[k])$display("ARCHITECTURAL_AUDIO_DIFFERENCE');
s=s.replace('future(k,0);end','if(k==15)begin $display("PASS MATRIX CHARACTERIZED RAW DEFECT 16 clocks; this is NOT a functional pass");$finish;end\nfuture(k,0);end');
fs.writeFileSync(file,s);fs.writeFileSync(p.join(dir,'cases.json'),JSON.stringify([{id:'bus_capture10_div14',args:{SEEK:10,DIVSEEK:14,BUS:1,REPLAYS:0,N:24000}}],null,2));
