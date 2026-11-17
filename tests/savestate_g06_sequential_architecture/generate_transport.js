const fs=require('fs'),p=require('path'),assert=require('assert'),d=__dirname;
const read=f=>fs.readFileSync(p.join(d,'baseline',f),'utf8').replace(/\r\n/g,'\n'),write=(f,s)=>fs.writeFileSync(p.join(d,'candidate_A',f),s);
let s=read('rtl/savestates.sv');
s=s.replace('reg [6:0] sprite_word;\nreg sprite_second, has_restart;','');
s=s.replace('input [4777:0] sprite_out, sprite2_out,',`input[31:0]sprite_state_rdata,
 output[7:0]sprite_state_addr,output sprite_state_second,sprite_state_read,sprite_state_write,
 output[31:0]sprite_state_wdata,
 input [4777:0] sprite_out, sprite2_out,`);
s=s.replace('reg [4799:0] sprite_snap, sprite2_snap;',`reg [6:0] sprite_word;
reg sprite_second,has_restart;
localparam ST_SP_SAVE_FETCH=7'd122,ST_SP_SAVE_WAIT=7'd123,ST_SP_LOAD_STORE=7'd124,
 ST_SP_LOAD_NEXT=7'd125,ST_SP_APPLY_WAIT=7'd126;
reg sp_capture,sp_apply,sp_bulk_read,sp_bulk_write,sp_apply_complete;
wire sp_done,sp_busy;
wire[63:0]sp_bulk_rdata;
wire[7:0]sp_bulk_addr=(sprite_second?8'd75:8'd0)+{1'b0,sprite_word};
sprite_snapshot sprite_memory(.clk(clk),.reset_n(reset_n),.capture(sp_capture),.apply_state(sp_apply),.legacy(!has_restart),.systeme(systeme),
 .bulk_read(sp_bulk_read),.bulk_write(sp_bulk_write),.bulk_addr(sp_bulk_addr),.bulk_wdata(dout_latch),.bulk_rdata(sp_bulk_rdata),.done(sp_done),.busy(sp_busy),
 .state_addr(sprite_state_addr),.state_second(sprite_state_second),.state_read(sprite_state_read),.state_write(sprite_state_write),.state_wdata(sprite_state_wdata),.state_rdata(sprite_state_rdata));`);
s=s.replace('assign sprite_in=sprite_snap[4777:0];','assign sprite_in=4778\'d0;').replace('assign sprite2_in=sprite2_snap[4777:0];','assign sprite2_in=4778\'d0;');
s=s.replace('sprite_second?sprite2_snap[63:0]:sprite_snap[63:0]','sp_bulk_rdata');
s=s.replaceAll('sprite_snap <= 0; sprite2_snap <= 0;','');
s=s.replace("            sprite_snap <= {22'd0,sprite_out};\n            sprite2_snap <= systeme ? {22'd0,sprite2_out} : 4800'd0;",'            sp_capture<=do_save;sp_apply_complete<=0;');
s=s.replace('fm_capture<=0;fm_apply<=0;fm_legacy<=0;fm_bulk_read<=0;fm_bulk_write<=0;has_fm<=0;', 'sp_capture<=0;sp_apply<=0;sp_bulk_read<=0;sp_bulk_write<=0;sp_apply_complete<=0;\n        fm_capture<=0;fm_apply<=0;fm_legacy<=0;fm_bulk_read<=0;fm_bulk_write<=0;has_fm<=0;');
s=s.replace('fm_capture<=0;fm_apply<=0;fm_legacy<=0;fm_bulk_read<=0;fm_bulk_write<=0;\n        // default','sp_capture<=0;sp_apply<=0;sp_bulk_read<=0;sp_bulk_write<=0;\n        fm_capture<=0;fm_apply<=0;fm_legacy<=0;fm_bulk_read<=0;fm_bulk_write<=0;\n        // default');
// Remove the old LOAD lookahead command; staging RAM is acknowledged first.
const cmd=s.indexOf('        ST_LOAD_SPRITE: if (!dout_expected'),cmdEnd=s.indexOf('\n',s.indexOf('ddram_cmd_read',cmd));assert(cmd>0&&cmdEnd>cmd);
s=s.slice(0,cmd)+s.slice(cmdEnd);
s=s.replaceAll('ST_SAVE_SPRITE_DESC: if (!DDRAM_BUSY)', 'ST_SAVE_SPRITE_DESC: if (!sp_busy && !DDRAM_BUSY)');
s=s.replace('sprite_word<=0;sprite_second<=0;state<=ST_SAVE_SPRITE;', 'sprite_word<=0;sprite_second<=0;state<=ST_SP_SAVE_FETCH;');
const start=s.indexOf('        ST_SAVE_SPRITE: if (!DDRAM_BUSY) begin'),end=s.indexOf('        ST_LOAD_SPRITE_DESC, ST_LOAD_PHASE, ST_LOAD_SPRITE: begin',start);assert(start>0&&end>start);
s=s.slice(0,start)+`        ST_SP_SAVE_FETCH:begin sp_bulk_read<=1;state<=ST_SP_SAVE_WAIT;end
        ST_SP_SAVE_WAIT:if(sp_done&&!sp_bulk_read)state<=ST_SAVE_SPRITE;
        ST_SAVE_SPRITE:if(!DDRAM_BUSY)begin
            ddram_write(base_addr+sprite_address,sprite_write_word,8'hff);
            state<=ST_SP_SAVE_FETCH;
            if(sprite_word==74)begin sprite_word<=0;sprite_second<=1;if(sprite_second)state<=ST_SAVE_BG_DESC;end
            else sprite_word<=sprite_word+7'd1;
        end
        ST_SP_LOAD_STORE:if(sp_done&&!sp_bulk_write)state<=ST_SP_LOAD_NEXT;
        ST_SP_LOAD_NEXT:if(!DDRAM_BUSY)begin
            if(sprite_second&&sprite_word==74)begin
              ddram_read(base_addr+(has_background?29'h032:29'h01f));state<=has_background?ST_LOAD_BG_DESC:ST_LOAD_EE_DESC;
            end else begin
              ddram_read(base_addr+sprite_address+29'd1);state<=ST_LOAD_SPRITE;
              if(sprite_word==74)begin sprite_word<=0;sprite_second<=1;end else sprite_word<=sprite_word+7'd1;
            end
        end
        ST_SP_APPLY_WAIT:if(sp_done&&!sp_apply)begin sp_apply_complete<=1;state<=ST_LOAD_RESTORE;end
`+s.slice(end);
const loadStart=s.indexOf('                        if (sprite_second) sprite2_snap'),loadEnd=s.indexOf('\n                    end\n                endcase',loadStart);assert(loadStart>0&&loadEnd>loadStart);
s=s.slice(0,loadStart)+'                        sp_bulk_write<=1;state<=ST_SP_LOAD_STORE;'+s.slice(loadEnd);
// New read states use the same combinational DDR command path as the FSM tasks.
const command=s.indexOf('        ST_FM_SAVE_WRITE:');assert(command>0);
s=s.slice(0,command)+`        ST_SP_LOAD_NEXT:if(!DDRAM_BUSY)ddram_cmd_read(base_addr+((sprite_second&&sprite_word==74)?(has_background?29'h032:29'h01f):sprite_address+29'd1));
`+s.slice(command);
const restore=s.indexOf('        ST_LOAD_RESTORE: begin'),restoreEnd=s.indexOf('\n        ST_FLUSH_PIPELINE: begin',restore);assert(restore>0&&restoreEnd>restore);
let body=s.slice(restore,restoreEnd);body=body.replace('ST_LOAD_RESTORE: begin',`ST_LOAD_RESTORE: begin
            if(!sp_apply_complete)begin sp_apply<=1;state<=ST_SP_APPLY_WAIT;end
            else begin`);const last=body.lastIndexOf('\n        end');body=body.slice(0,last)+'\n            end'+body.slice(last);s=s.slice(0,restore)+body+s.slice(restoreEnd);
assert(!/\bsprite2?_snap\b/.test(s),'old banks remain');assert(s.includes('sp_apply_complete<=0;'));
write('rtl/savestates.sv',s);
// Experimental hierarchy only; keep legacy aliases available to test probes.
let sys=read('rtl/system.vhd');sys=sys.replace('ss_sprite_valid : in std_logic',`ss_state_addr:in std_logic_vector(7 downto 0);ss_state_second,ss_state_read,ss_state_write:in std_logic;
 ss_state_wdata:in std_logic_vector(31 downto 0);ss_state_rdata:out std_logic_vector(31 downto 0);
 ss_sprite_valid : in std_logic`);
const ai=sys.indexOf('architecture '),is=sys.indexOf(' is',ai);sys=sys.slice(0,is+3)+'\n signal ss_sprite_data1,ss_sprite_data2:std_logic_vector(31 downto 0);'+sys.slice(is+3);
const begin=sys.indexOf('\nbegin',is);assert(begin>0);sys=sys.slice(0,begin)+sys.slice(begin).replace('\nbegin',"\nbegin\n ss_state_rdata<=ss_sprite_data2 when ss_state_second='1' else ss_sprite_data1;");
for(const [id,dev]of [['','1'],['2','2']]){const marker=`ss_sprite_out=>ss_sprite${id}_out,`;const expr=dev==='1'?"not ss_state_second":"ss_state_second";assert(sys.includes(marker));sys=sys.replace(marker,`ss_state_addr=>ss_state_addr,ss_state_read=>ss_state_read and (${expr}),ss_state_write=>ss_state_write and (${expr}),ss_state_wdata=>ss_state_wdata,ss_state_rdata=>ss_sprite_data${dev},\n`+marker);}
write('rtl/system.vhd',sys);
let top=read('SMS.sv');top=top.replace('wire ss_sprite_valid;',`wire ss_sprite_valid;wire[7:0]ss_state_addr;wire ss_state_second,ss_state_read,ss_state_write;wire[31:0]ss_state_wdata,ss_state_rdata;`);
top=top.replace('.ss_sprite_out(ss_sprite_out),',`.ss_state_addr(ss_state_addr),.ss_state_second(ss_state_second),.ss_state_read(ss_state_read),.ss_state_write(ss_state_write),.ss_state_wdata(ss_state_wdata),.ss_state_rdata(ss_state_rdata),\n    .ss_sprite_out(ss_sprite_out),`);
top=top.replace('.sprite_out(ss_sprite_out),',`.sprite_state_addr(ss_state_addr),.sprite_state_second(ss_state_second),.sprite_state_read(ss_state_read),.sprite_state_write(ss_state_write),.sprite_state_wdata(ss_state_wdata),.sprite_state_rdata(ss_state_rdata),\n    .sprite_out(ss_sprite_out),`);write('SMS.sv',top);
let qip=read('files.qip');qip='set_global_assignment -name VHDL_FILE rtl/sprite_state_pkg.vhd\n'+qip+'\nset_global_assignment -name SYSTEMVERILOG_FILE rtl/sprite_snapshot.sv\n';write('files.qip',qip);
console.log('Generated isolated RAM transport and hierarchy. F01 implementation and v17 layout unchanged.');
