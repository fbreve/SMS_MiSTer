const fs=require('fs'),p=require('path'),d=__dirname,dst=p.join(d,'peripherals');fs.mkdirSync(dst,{recursive:true});
let tb=fs.readFileSync(p.join(d,'miter/miter.sv'),'utf8');tb=tb.slice(0,tb.indexOf('reg[63:0]image[0:12287]'));
tb+=`initial begin
 for(integer w=0;w<12288;w++)mem[w]=0;
 repeat(4)tick;reset_n=1;active=1;expect_background=1;
 for(profile=0;profile<16;profile++)begin
  systeme=profile&1;logical_pause=(profile>>1)&1;
  md_out={3'd0,3'd4,17'd57001,3'd0,3'd3,17'd33445}+profile;
  gg_out=128'h00001fe00003f8000000ffa07fff00ff^(128'd1<<profile);
  tap_out={3'd5,16'd3344}+profile;
  paddle_out={12'd2345,20'h52693}+profile;
  gun_out=46'h31bc892468ab^profile;
  eeprom_present=(profile>>2)&1;eeprom_out=64'h891235110088cc01^profile;
  eeprom_ext_out=128'h00000000891235017892345678912345^profile;
  sc_ram_size=(profile>>2)&3;
  io_out=32'h91223456^profile;
  transfer(1);repeat(3)transfer(0);
  if(!md_valid||!tap_valid||!paddle_valid||!gun_valid)$fatal(1,"valid peripheral record not restored");
  if(md_in!==md_out||tap_in!==tap_out||paddle_in!==paddle_out||gun_in!==gun_out||gg_in!==gg_out)$fatal(1,"peripheral roundtrip mismatch");
  $display("PASS PERIPHERALS profile%0d owner%b pause%b sc%0d eeprom%b",profile,systeme,logical_pause,sc_ram_size,eeprom_present);
 end
 $display("PASS PERIPHERALS ALL outputs101 profiles16 loads48 clocks%0d",cycles);$finish;
end
initial begin #1000000000;$fatal(1,"watchdog");end
endmodule
`;
for(const f of ['golden.sv','candidate.sv'])fs.copyFileSync(p.join(d,'miter',f),p.join(dst,f));
fs.writeFileSync(p.join(dst,'miter.sv'),tb);fs.copyFileSync(p.join(d,'miter/run.do'),p.join(dst,'run.do'));
