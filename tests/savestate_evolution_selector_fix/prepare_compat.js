const fs=require('fs'),path=require('path'),d=__dirname,r=path.resolve(d,'../..'),old=path.join(r,'tests/savestate_mapper_detection_fix');
let s=fs.readFileSync(path.join(old,'format_tb.sv'),'utf8').replaceAll('48430a','48430b').replace('if(header[63:38]!=={24\'h484309','if(header[63:38]!=={24\'h48430a');
s=s.replace('wire [95:0] evolution_in;','wire [159:0] evolution_in;');
s=s.replace('if(mapper_history_in!==expected_history)',"if(evolution_in[159:96]!==0)$fatal(1,\"non-Evolution history was not normalized\");\n  if(mapper_history_in!==expected_history)");
s=s.replace('k<24','k<30').replace('    9:expected_history','    9:expected_history');
s=s.replace('   23:mem[\'h1a][63:40]=24\'h484308;',`   23:mem['h1a][63:40]=24'h484308;
   24:begin mem['h1a][63:40]=24'h484309;expected_history=historyword[17:0];end
   25:begin mem['h2d]=0;expected_history=historyword[17:0];end
   26:begin mem['h2c]='1;expected_history=historyword[17:0];end
   27:begin mem['h2d]='1;expected_history=historyword[17:0];end
   28:begin mem['h1a][63:40]=24'h484309;mem['h2c]='1;mem['h2d]='1;expected_history=historyword[17:0];end
   29:begin mem['h1a][63:40]=24'h48430b;end`);
s=s.replace("header=mem['h1a];historyword=mem['h2a];desc=mem['h2b];", "header=mem['h1a];historyword=mem['h2a];desc=mem['h2b];");
s=s.replace("mem['h2a]=historyword;mem['h2b]=desc;", "mem['h2a]=historyword;mem['h2b]=desc;mem['h2c]=0;mem['h2d]=64'h0000003945563130;");
// future-version rejection intentionally does not inherit any old extension.
s=s.replace('if(k>=2&&k<=9||k>=11&&k<=15||k>=18)', 'if(k>=2&&k<=9||k>=11&&k<=15||k>=18&&k<=28)');
for(const min of [3,6,7])s=s.replace(`if(k>=${min}&&k<=9||k>=11&&k<=15||k>=18)`,`if(k>=${min}&&k<=9||k>=11&&k<=15||k>=18&&k<=28)`);
s=s.replace('if(k==8||k==9||k>=11&&k<=15||k>=18)','if(k==8||k==9||k>=11&&k<=15||k>=18&&k<=28)');
s=s.replace('untagged v1-v9 future','untagged v1-v10 future');
fs.writeFileSync(path.join(d,'compat_tb.sv'),s.replace('module format_tb;','module compat_tb;'));
let script=fs.readFileSync(path.join(d,'f13_run.do'),'utf8').replaceAll('f13_work','compat_work').replace('f13_history_tb.sv','compat_tb.sv').replace('compat_work.history_tb -gCASE=$env(F13_CASE)','compat_work.compat_tb');
fs.writeFileSync(path.join(d,'compat.do'),script);
