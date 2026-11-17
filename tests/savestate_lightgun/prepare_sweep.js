const fs=require('fs'),path=require('path'),d=__dirname;
let p=fs.readFileSync(path.join(d,'probe.sv'),'utf8');
p=p.replace('module probe;','module sweep;parameter PX=255,PY=252,MODE=0;').replace(".smode_M1(1'd0),.smode_M2(1'd0),.smode_M3(1'd0)",".smode_M1(MODE==1),.smode_M2(MODE!=0),.smode_M3(MODE==2)");
p=p.replace(".JOY_X(8'h7f),.JOY_Y(8'h7c)",".JOY_X(jx),.JOY_Y(jy)").replace('wire sensor;gun_fixture','reg[7:0]jx=8\'h7f,jy=8\'h7c;wire sensor;gun_fixture');
// Match the production CPU/pixel enable phase for potential acceptance points.
p=p.replace('reg[3:0]div=0;wire ce_pix=div==0;always@(negedge clk)div=div==9?0:div+1;',"reg[4:0]div=0;reg ce_pix=0,ce_cpu=0;always@(negedge clk)begin ce_pix<=div==9||div==19||div==29;ce_cpu<=div==9||div==24;div<=div==29?0:div+1;end ");
p=p.slice(0,p.indexOf('integer frame=0;'))+`integer frame=0,eligible=0,active=0,firstx=999,lastx=0,firsty=999,lasty=0,rises=0,falls=0,hderises=0,hdefalls=0;reg last_sensor=0,last_hde=0,eligible_sample;
always@(posedge vb)begin frame=frame+1;if(frame==3)begin jx=PX^128;jy=PY^128;end end
always@(posedge clk)begin
eligible_sample=frame==4&&ce_cpu&&vb&&x<256;#1;
if(frame==4)begin
if(sensor&&!last_sensor)rises=rises+1;if(!sensor&&last_sensor)falls=falls+1;
if(!hb&&!last_hde)hderises=hderises+1;if(hb&&last_hde)hdefalls=hdefalls+1;
end
if(eligible_sample)begin
eligible=eligible+1;
if(sensor)begin active=active+1;if(x<firstx)firstx=x;if(x>lastx)lastx=x;if(y<firsty)firsty=y;if(y>lasty)lasty=y;end
end
last_sensor=sensor;last_hde=!hb;
end
initial begin wait(frame==5);$display("PASS REACHABILITY PAL%0d BORDER%0d MODE%0d PX%0d PY%0d potentialCPUboundaries%0d sensorHigh%0d savedXrange%0d..%0d Yrange%0d..%0d sensorEdges%0d/%0d HDEedges%0d/%0d",PAL,BORDER,MODE,PX,PY,eligible,active,active?firstx:-1,active?lastx:-1,active?firsty:-1,active?lasty:-1,rises,falls,hderises,hdefalls);$finish;end
initial begin #90000000;$fatal(1,"sweep watchdog");end
endmodule
`;
fs.writeFileSync(path.join(d,'sweep.sv'),p);
const targets=[[0,0],[0,128],[1,252],[128,128],[240,252],[254,252],[255,252],[255,248],[255,255],[255,0],[255,1],[255,128]];
const configs=[];for(let pal=0;pal<2;pal++)for(let mode=0;mode<3;mode++)configs.push({pal,mode,border:0});for(let pal=0;pal<2;pal++)configs.push({pal,mode:0,border:1});
let cases=[];for(let c=0;c<configs.length;c++)for(const [px,py]of(c===0?targets:[[255,252],[255,255],[0,128]]))cases.push({...configs[c],px,py});
for(let i=0;i<cases.length;i++){const c=cases[i],g=i%6;fs.writeFileSync(path.join(d,`sweep_case${i}.do`),`onerror {quit -code 1}\nonbreak {quit -code 1}\nvlib sweep${g}_work\nvcom -work sweep${g}_work -2008 -quiet ../../rtl/video.vhd\nvlog -work sweep${g}_work -sv -quiet gun_fixture.sv sweep.sv\nvsim -c -gPAL=${c.pal} -gBORDER=${c.border} -gMODE=${c.mode} -gPX=${c.px} -gPY=${c.py} sweep${g}_work.sweep\nset StdArithNoWarnings 1\nrun -all\nquit -code 0\n`);}
fs.writeFileSync(path.join(d,'sweep_cases.json'),JSON.stringify(cases,null,2)+'\n');
