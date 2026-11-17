const fs=require('fs'),p=require('path'),d=p.join(__dirname,'local_gate');fs.mkdirSync(d,{recursive:true});
let q=fs.readFileSync(p.join(__dirname,'memory_gate/snapshot.qsf'),'utf8').replace('TOP_LEVEL_ENTITY opll_snapshot','TOP_LEVEL_ENTITY opll').replace(/set_global_assignment -name SYSTEMVERILOG_FILE[^\n]+/,'set_global_assignment -name QIP_FILE ../../../rtl/VM2413/OPLL.qip');
fs.writeFileSync(p.join(d,'opll.qsf'),q);fs.writeFileSync(p.join(d,'opll.qpf'),'PROJECT_REVISION = "opll"\n');
