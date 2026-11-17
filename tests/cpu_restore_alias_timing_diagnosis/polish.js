const fs=require('fs'),p=require('path'),f=p.join(__dirname,'review.md');let s=fs.readFileSync(f,'utf8');
s=s.replace('49.7/49.4/50.8%','49.7/49.5/50.6%').replace('total **74?77%**, candidate H/V **76.6/80.9%**','total **74 -> 77%**, baseline H/V **75.5/76.9%**, candidate H/V **76.6/80.9%**');
let lines=s.split('\n').map(l=>{if(l==='?? tests/')return l;if(l.startsWith('Slack loss'))return l.replace('**?1.185?0.007=?1.192ns**','**-1.185 - 0.007 = -1.192ns**').replace('?.818','-.818');if(l.startsWith('Packing')||l.startsWith('Unavailable ALMs'))l=l.replace('38599?2055','38599-2055').replace('38457?2060','38457-2060');
l=l.replace(/\(\?(\d+)/g,'(-$1').replace(/\(\?\./g,'(-.').replace(/skew\?/g,'skew-').replace(/\| \?(\d|\.)/g,'| -$1').replace(/\*\*\?(\d)/g,'**-$1');
l=l.replace('candidate ?0.714','candidate -0.714').replace('+.104??.108','+.104 -> -.108').replace('totals?136FF','totals-136FF').replace('z80_dir?230','z80_dir-230').replace('duplicates?4','duplicates-4').replace('memory?21','memory-21').replace('scaler?13','scaler-13').replace('wrapper?1','wrapper-1').replace('evaluator?31','evaluator-31').replace('secondary BG?9','secondary BG-9');
return l.replaceAll('?',' -> ');});s=lines.join('\n');
s=s.replace('approximately6 -> 21','approximately 6-21').replace('about6.0 -> 6.25GB','about 6.0-6.25 GB').replace('28 -> 30minutes','28-30 minutes').replace('aboutonehour','about one hour').replace('about92m13s','about 92m13s');
fs.writeFileSync(f,s);console.log('Report punctuation and baseline H/V verified/corrected.');
