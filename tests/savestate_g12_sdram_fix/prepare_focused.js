const fs=require('fs'),p=require('path'),d=__dirname;
fs.writeFileSync(p.join(d,'final_matrix/focused_cases.json'),JSON.stringify([
 {id:'gg_normal_rom',args:{DUAL:5,BOOT:1200,N:6000,REPLAYS:3,TAC:3}},
 {id:'systeme_tac7_rom',args:{DUAL:0,BOOT:1200,N:6000,REPLAYS:3,TAC:7}}
],null,2));
