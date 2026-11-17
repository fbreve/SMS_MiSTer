// Prepare reviewable candidate files in this test tree ONLY. Applying them to
// production is a separate step, permitted only after the pre-edit proof gate.
const fs=require('fs'),p=require('path'),rep=require('./background_representation');
const d=__dirname,root=p.resolve(d,'../..'),dst=p.join(d,'proposed');
const read=f=>fs.readFileSync(p.join(root,f),'utf8').replace(/\r\n/g,'\n');
const write=(f,s)=>{const target=p.join(dst,f);fs.mkdirSync(p.dirname(target),{recursive:true});fs.writeFileSync(target,s);};
const replace=(s,a,b)=>{if(s.split(a).length!==2)throw Error('Nonunique/missing anchor '+a.slice(0,100));return s.replace(a,b);};
const ports=`ss_bg_out: out std_logic_vector(138 downto 0);
 ss_bg_in: in std_logic_vector(138 downto 0) := (others=>'0');
 ss_bg_valid: in std_logic := '0';\n `;
write('rtl/vdp_background.vhd',rep.proposal(read('rtl/vdp_background.vhd')));
let s=read('rtl/vdp_main.vhd');s=replace(s,'ss_sprite_out: out',ports+'ss_sprite_out: out');s=replace(s,'\t\tss_restore\t\t\t=> ss_regs_set,','        ss_bg_out=>ss_bg_out,ss_bg_in=>ss_bg_in,ss_bg_valid=>ss_bg_valid,\n\t\tss_restore\t\t\t=> ss_regs_set,');write('rtl/vdp_main.vhd',s);
s=read('rtl/vdp.vhd');s=replace(s,'ss_sprite_out: out',ports+'ss_sprite_out: out');s=replace(s,'ss_sprite_out=>ss_sprite_out(', 'ss_bg_out=>ss_bg_out,ss_bg_in=>ss_bg_in,ss_bg_valid=>ss_bg_valid,\n        ss_sprite_out=>ss_sprite_out(');write('rtl/vdp.vhd',s);
s=read('rtl/system.vhd');s=replace(s,'ss_sprite_out, ss_sprite2_out : out',`ss_bg_out, ss_bg2_out : out std_logic_vector(138 downto 0);
        ss_bg_in, ss_bg2_in : in std_logic_vector(138 downto 0) := (others=>'0');
        ss_bg_valid : in std_logic := '0';
        ss_sprite_out, ss_sprite2_out : out`);
s=replace(s,'ss_sprite_out=>ss_sprite_out,','ss_bg_out=>ss_bg_out,ss_bg_in=>ss_bg_in,ss_bg_valid=>ss_bg_valid,\n\t\tss_sprite_out=>ss_sprite_out,');
s=replace(s,'ss_sprite_out=>ss_sprite2_out,','ss_bg_out=>ss_bg2_out,ss_bg_in=>ss_bg2_in,ss_bg_valid=>ss_bg_valid,\n\t\tss_sprite_out=>ss_sprite2_out,');write('rtl/system.vhd',s);
s=read('SMS.sv');s=replace(s,'wire ss_sprite_valid;',`wire ss_sprite_valid;
wire [138:0] ss_bg_out,ss_bg2_out,ss_bg_in,ss_bg2_in;
wire ss_bg_valid;`);
s=replace(s,'    .ss_sprite_out(ss_sprite_out),',`    .ss_bg_out(ss_bg_out),.ss_bg2_out(ss_bg2_out),.ss_bg_in(ss_bg_in),.ss_bg2_in(ss_bg2_in),.ss_bg_valid(ss_bg_valid),
    .ss_sprite_out(ss_sprite_out),`);
s=replace(s,'    .sprite_out(ss_sprite_out),',`    .bg_out(ss_bg_out),.bg2_out(ss_bg2_out),.bg_in(ss_bg_in),.bg2_in(ss_bg2_in),.bg_valid(ss_bg_valid),
    .sprite_out(ss_sprite_out),`);write('SMS.sv',s);
s=read('rtl/savestates.sv');
s=replace(s,'    input [4777:0] sprite_out, sprite2_out,',`    // v15 minimal live background history, independently owned per VDP.
    input [138:0] bg_out, bg2_out,
    output [138:0] bg_in, bg2_in,
    output bg_valid,
    input [4777:0] sprite_out, sprite2_out,`);
s=replace(s,"localparam [23:0] RESTART_MAGIC = 24'h48430e;",`localparam [23:0] RESTART_MAGIC = 24'h48430e;
localparam [23:0] BACKGROUND_MAGIC = 24'h48430f;
localparam [63:0] BACKGROUND_DESC = {16'd139,8'd15,8'd0,32'h47354231};
localparam ST_SAVE_BG_DESC=7'd107, ST_SAVE_BG=7'd108,
           ST_LOAD_BG_DESC=7'd109, ST_LOAD_BG=7'd110;
reg [138:0] bg_snap,bg2_snap;
reg [1:0] bg_word;
reg bg_second,has_background;
assign bg_in=bg_snap;
assign bg2_in=bg2_snap;
assign bg_valid=has_background;
wire [28:0] bg_address=29'h033+(bg_second?29'd3:29'd0)+{27'd0,bg_word};
// Three sequential transfers over139 useful bits: rotate64/64/11 on SAVE,
// shift64/64/11 on LOAD. No padded register bank or indexed wide crossbar.
wire [63:0] bg_write_word=bg_second ?
    (bg_word==2?{53'd0,bg2_snap[10:0]}:bg2_snap[63:0]) :
    (bg_word==2?{53'd0,bg_snap[10:0]}:bg_snap[63:0]);
`);
s=replace(s,'reg [63:0]  dout_latch;',`reg [63:0]  dout_latch;
wire bg_word_invalid=(bg_word==2 && dout_latch[63:11]!=0) ||
    (bg_word==0 && dout_latch[22:15]>=8'd240) ||
    (bg_second && !systeme && dout_latch!=0);`);
s=replace(s,'wire [63:0] video_word = {RESTART_MAGIC,','wire [63:0] video_word = {BACKGROUND_MAGIC,');
s=replace(s,'wire modern_restart_tag = dout_latch[63:40] == CPU_RESTART_MAGIC || dout_latch[63:40] == RESTART_MAGIC;','wire modern_restart_tag = dout_latch[63:40] == CPU_RESTART_MAGIC || dout_latch[63:40] == RESTART_MAGIC || dout_latch[63:40] == BACKGROUND_MAGIC;');
s=s.replaceAll('has_restart <= 0; phase_snap <= 0; sprite_snap <= 0; sprite2_snap <= 0;',`has_restart <= 0; phase_snap <= 0; sprite_snap <= 0; sprite2_snap <= 0;
        has_background<=0;bg_snap<=0;bg2_snap<=0;bg_word<=0;bg_second<=0;`);
s=replace(s,"            sprite_snap <= {22'd0,sprite_out};",`            bg_snap<=bg_out;bg2_snap<=systeme?bg2_out:139'd0;
            has_background<=1;
            sprite_snap <= {22'd0,sprite_out};`);
s=replace(s,'has_restart <= dout_latch[63:40] == RESTART_MAGIC;',`has_restart <= dout_latch[63:40] == RESTART_MAGIC || dout_latch[63:40] == BACKGROUND_MAGIC;
                has_background <= dout_latch[63:40] == BACKGROUND_MAGIC;`);
s=replace(s,'if (sprite_second) state<=ST_SAVE_EE_DESC;','if (sprite_second) state<=ST_SAVE_BG_DESC;');
s=replace(s,"ddram_cmd_read(base_addr+((sprite_second && sprite_word==74)?29'h01f:sprite_address+29'd1));",`ddram_cmd_read(base_addr+((sprite_second && sprite_word==74)?(has_background?29'h032:29'h01f):sprite_address+29'd1));
        ST_SAVE_BG_DESC: if (!DDRAM_BUSY) ddram_cmd_write(base_addr+29'h032,BACKGROUND_DESC,8'hff);
        ST_SAVE_BG: if (!DDRAM_BUSY) ddram_cmd_write(base_addr+bg_address,bg_write_word,8'hff);
        ST_LOAD_BG_DESC: if (!dout_expected && !DDRAM_BUSY && dout_latch==BACKGROUND_DESC) ddram_cmd_read(base_addr+29'h033);
        ST_LOAD_BG: if (!dout_expected && !DDRAM_BUSY && !bg_word_invalid)
            ddram_cmd_read(base_addr+((bg_second && bg_word==2)?29'h01f:bg_address+29'd1));`);
s=replace(s,"                            ddram_read(base_addr+29'h01f);state<=ST_LOAD_EE_DESC;",`                            ddram_read(base_addr+(has_background?29'h032:29'h01f));
                            state<=has_background?ST_LOAD_BG_DESC:ST_LOAD_EE_DESC;`);
s=replace(s,'        ST_SAVE_EVOLUTION1: begin\n            if (!DDRAM_BUSY) begin\n                ddram_write',`        ST_SAVE_BG_DESC: if (!DDRAM_BUSY) begin
            ddram_write(base_addr+29'h032,BACKGROUND_DESC,8'hff);
            bg_word<=0;bg_second<=0;state<=ST_SAVE_BG;
        end
        ST_SAVE_BG: if (!DDRAM_BUSY) begin
            ddram_write(base_addr+bg_address,bg_write_word,8'hff);
            if (bg_second) begin
                if (bg_word==2) bg2_snap<={bg2_snap[10:0],bg2_snap[138:11]};
                else bg2_snap<={bg2_snap[63:0],bg2_snap[138:64]};
            end else begin
                if (bg_word==2) bg_snap<={bg_snap[10:0],bg_snap[138:11]};
                else bg_snap<={bg_snap[63:0],bg_snap[138:64]};
            end
            if (bg_word==2) begin
                bg_word<=0;bg_second<=1;
                if (bg_second) state<=ST_SAVE_EE_DESC;
            end else bg_word<=bg_word+2'd1;
        end
        ST_LOAD_BG_DESC,ST_LOAD_BG: begin
            if (DDRAM_DOUT_READY && dout_expected) begin
                dout_expected<=0;dout_latch<=DDRAM_DOUT;
            end else if (!dout_expected && !DDRAM_BUSY) begin
                if (state==ST_LOAD_BG_DESC) begin
                    if (dout_latch!=BACKGROUND_DESC) state<=ST_ERROR;
                    else begin bg_word<=0;bg_second<=0;ddram_read(base_addr+29'h033);state<=ST_LOAD_BG;end
                end else if (bg_word_invalid) state<=ST_ERROR;
                else begin
                    if (bg_second) begin
                        if (bg_word==2) bg2_snap<={dout_latch[10:0],bg2_snap[138:11]};
                        else bg2_snap<={dout_latch,bg2_snap[138:64]};
                    end else begin
                        if (bg_word==2) bg_snap<={dout_latch[10:0],bg_snap[138:11]};
                        else bg_snap<={dout_latch,bg_snap[138:64]};
                    end
                    if (bg_second && bg_word==2) begin ddram_read(base_addr+29'h01f);state<=ST_LOAD_EE_DESC;end
                    else begin
                        ddram_read(base_addr+bg_address+29'd1);
                        if (bg_word==2) begin bg_word<=0;bg_second<=1;end
                        else bg_word<=bg_word+2'd1;
                    end
                end
            end
        end
        ST_SAVE_EVOLUTION1: begin
            if (!DDRAM_BUSY) begin
                ddram_write`);
s=replace(s,'//   v14 tag=48430e, subtype3, retaining the v13 CPU word layout.',`//   v15 tag=48430f adds139-bit background records, retaining v14 restart.
//   Word032: width139/version15/G5B1; words033..038: two padded records.
//   v14 tag=48430e, subtype3, retaining the v13 CPU word layout.`);
write('rtl/savestates.sv',s);
console.log('Prepared six proposed G05-only production files in test tree; working RTL unchanged');
