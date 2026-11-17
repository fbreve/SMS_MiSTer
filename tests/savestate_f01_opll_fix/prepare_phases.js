const fs=require('fs'),p=require('path'),d=__dirname;
let s=fs.readFileSync(p.join(d,'local_tb.vhd'),'utf8').replace('library original_work;','library original_work;library local_work;').replaceAll('local_tb','phase_tb').replace('entity work.opll','entity local_work.opll').replace('variable image:memory; variable baseline:memory;','variable image:memory; variable baseline:memory; variable check:memory;');
s=s.replace("addr<=x\"ff\";a<=ra;d<=rd;for i in 1 to 8 loop host;end loop;",`addr<=x"ff";a<=ra;d<=rd;for i in 1 to 8 loop host;end loop;
   capture(check);for i in 0 to 103 loop assert check(i)=baseline(i) report "roundtrip word "&integer'image(i) severity failure;end loop;
   addr<=x"ff";for i in 1 to 8 loop host;end loop;`);
fs.writeFileSync(p.join(d,'phase_tb.vhd'),s);
fs.writeFileSync(p.join(d,'phase_compile.do'),'onerror {quit -code 1}\nvlib phase_work\nvcom -work phase_work -2008 phase_tb.vhd\nquit -code 0\n');
fs.writeFileSync(p.join(d,'phase_run.do'),'onerror {quit -code 1}\nonbreak {quit -code 1}\nvsim -t 1ps phase_work.phase_tb -gSHIFT=$env(SHIFT) -gSTALL=$env(STALL)\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n');
