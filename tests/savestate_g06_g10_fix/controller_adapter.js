const fs=require('fs'),p=require('path');
module.exports=function adapter(file,fast=true){let s=fs.readFileSync(file,'utf8').replace(/\r\n/g,'\n');
 s=s.replace('reg  [63:0] mapper_snap;','').replace('reg [159:0] evolution_snap;','').replace('wire evolution_state =','reg [63:0] mapper_snap;reg [159:0] evolution_snap;\nwire evolution_state =');
 if(fast)s=s.replace('module savestates (','module savestates #(parameter TB_FAST=0) (').replace("20'd900000;","(TB_FAST?20'd0:20'd900000);");return s;};
