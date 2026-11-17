const fs=require('fs'),p=require('path'),d=__dirname,dst=p.join(d,'evolution');fs.mkdirSync(dst,{recursive:true});
let tb=fs.readFileSync(p.join(d,'miter/miter.sv'),'utf8');tb=tb.slice(0,tb.indexOf('reg[63:0]image[0:12287]'));
tb+=`reg[63:0]image[0:12287];
initial begin
 for(integer w=0;w<12288;w++)mem[w]=0;
 repeat(4)tick;reset_n=1;active=1;expect_background=1;
 for(profile=0;profile<8;profile++)begin
  evolution_out=160'h00000000000000000000891234568912e1322468;
  evolution_out[155:96]=60'h123456789abcde; evolution_out[155:153]=profile;
  transfer(1);for(integer w=0;w<12288;w++)image[w]=mem[w];
  repeat(3)begin transfer(0);if(evolution_in!==evolution_out)$fatal(1,"Evolution history changed");end
  mem['h1a][63:22]=0;mem['he][63:52]=0;mem[5][63:38]=0;
  transfer(0);if(guest_writes)$fatal(1,"missing Evolution public history invented");
  mem[0][63:32]=32'h3ffe;mem[5][63:20]=0;
  transfer(0);if(guest_writes)$fatal(1,"old64 Evolution history invented");
  $display("PASS EVOLUTION profile%0d current3 public_reject2",profile);
 end
 $display("PASS EVOLUTION ALL outputs101 profiles8 current24 public_rejections16 clocks%0d",cycles);$finish;
end
initial begin #1000000000;$fatal(1,"watchdog");end
endmodule
`;
for(const f of ['golden.sv','candidate.sv'])fs.copyFileSync(p.join(d,'miter',f),p.join(dst,f));fs.writeFileSync(p.join(dst,'miter.sv'),tb);fs.copyFileSync(p.join(d,'miter/run.do'),p.join(dst,'run.do'));
