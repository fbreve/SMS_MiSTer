const fs=require('fs'),path=require('path'),d=__dirname,r=path.resolve(d,'../..');
const before=process.env.PADDLE_BEFORE==='1';
const s=fs.readFileSync(path.join(r,before?'tests/savestate_paddle/baseline/SMS.sv':'SMS.sv'),'utf8').replace(/\r\n/g,'\n');
let body=s.slice(s.indexOf('reg  [3:0] paddle_0_nib'),s.indexOf('\nreg dbg_menu')).trim();
body=body.replaceAll('always_ff @(posedge clk_sys) begin','always_ff @(posedge clk_sys) begin\nif (!hold) begin').replaceAll('\nend\n','\nend\nend\n');
body=body.replace('wire       en16khz;','').replace('reg [11:0] cnt_en16khz;','');
body='wire en16khz;reg[11:0]cnt_en16khz;\n'+body;
const state='{cnt_en16khz,joyb_th_out_q,joya_th_out_q,paddle_1_tr,paddle_0_tr,paddle_1_nib_q,paddle_1_nib,paddle_0_nib_q,paddle_0_nib}';
fs.writeFileSync(path.join(d,before?'before_fixture.sv':'paddle_fixture.sv'),`module paddle_fixture(input clk_sys,hold,ss_freeze,ss_set,ss_valid,jp_region,paddle_joy,input[31:0]ss_in,input[7:0]paddle_0,paddle_1,joy0_x,joy1_x,input joya_th_out,joyb_th_out,output[31:0]state,output[9:0]pins);
wire ss_paddle_set=ss_set,ss_paddle_valid=ss_valid;wire[31:0]ss_paddle_in=ss_in;
${body}
assign state=${state};assign pins={paddle_1_tr,paddle_1_nib,paddle_0_tr,paddle_0_nib};
endmodule\n`);
