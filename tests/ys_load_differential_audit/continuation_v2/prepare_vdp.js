const fs=require('fs'),p=require('path'),cp=require('child_process');const d=__dirname,root=p.resolve(d,'../../..');
const get=f=>cp.execFileSync('git',['show','66f16d5c:'+f],{cwd:root,encoding:'utf8'}).replace(/\r\n/g,'\n');
for(const f of ['video.vhd','dpram.vhd','vdp_cram.vhd','vdp_background.vhd','vdp_sprite_shifter.vhd','vdp_sprites.vhd','vdp_main.vhd','vdp.vhd']){
 let s=get('rtl/'+f);
 if(f==='dpram.vhd')s=s.replace('string := " "','string := "UNUSED"'); // vendor simulation requires a nonblank sentinel
 if(f==='vdp.vhd')s=s.replace('ss_regs_out    : out',`TestWE : out std_logic; TestWA : out std_logic_vector(14 downto 0); TestWD : out std_logic_vector(7 downto 0);
 ss_regs_out    : out`).replace('mask_column <= mask_column0;',`TestWE<=vram_portA_wren;TestWA<=vram_portA_address;TestWD<=vram_portA_data;
 mask_column <= mask_column0;`);
 fs.writeFileSync(p.join(d,f),s);
}
let tb=fs.readFileSync(p.join(d,'cpu_matrix_tb.sv'),'utf8').replace('module cpu_matrix_tb;','module cpu_vdp_tb;');
tb=tb.replace('reg [1:0] previous_wr',`reg run_vdp=1;reg [2:0] vp=0;
 wire [127:0] vdpr[2];wire [383:0] cr[2];wire [7:0] vdpd[2],vwd[2];wire [14:0] vwa[2];wire [1:0] vwe;
 reg [127:0] vdpsnap;reg vset=0,initVDP=0;
 reg [22:0] vram_events[2][512];integer vram_count[2];
 always @(negedge clk) vp=(vp+1)%5;
 for(genvar v=0;v<2;v++)begin:video_access
 vdp vdp_unit(.clk_sys(clk),.ce_vdp(run_vdp&&vp==0&&!vset),.ce_pix(1'b0),.ce_sp(1'b0),.gg(1'b0),.ggres(1'b0),.se_bank(1'b0),.sp64(1'b0),.HL(1'b0),.mask_line_irq(1'b0),.capture_cpu_edges(1'b0),.legacy_ext_nt(1'b0),.RD_n(rd[v]|iorq[v]|(a[v][7:6]!=2'b10)),.WR_n(wr[v]|iorq[v]|(a[v][7:6]!=2'b10)),.IRQ_n(),.WR_direct(1'b0),.A_direct(6'd0),.A(a[v][7:0]),.D_in(dout[v]),.D_out(vdpd[v]),.x(9'd100),.y(9'd240),.vcounter_cpu(8'd240),.color(),.palettemode(1'b0),.y1(),.mask_column(),.black_column(1'b0),.smode_M1(),.smode_M2(),.smode_M3(),.smode_M4(),.ysj_quirk(1'b0),.reset_n(reset_n),.ss_regs_out(vdpr[v]),.ss_regs_in(vdpsnap),.ss_regs_set(vset&&(v==1||initVDP)),.ss_cram_out(cr[v]),.ss_cram_wr(1'b0),.ss_cram_A(5'd0),.ss_cram_D(12'd0),.ss_vram_en(1'b0),.ss_vram_A(15'd0),.ss_vram_D(),.ss_vram_WE(1'b0),.ss_vram_WA(15'd0),.ss_vram_WD(8'd0),.TestWE(vwe[v]),.TestWA(vwa[v]),.TestWD(vwd[v]));
 always @(posedge clk)if(reset_n&&vwe[v]&&vram_count[v]<512)begin vram_events[v][vram_count[v]]<={vwa[v],vwd[v]};vram_count[v]<=vram_count[v]+1;end
 end
 reg [1:0] previous_wr`);
tb=tb.replace("!iorq[i]?8'hff:mem[i][a[i]]","!iorq[i]?(a[i][7:6]==2'b10 ? vdpd[i]:8'hff):mem[i][a[i]]");
tb=tb.replace('io_count[0]=0;io_count[1]=0;','io_count[0]=0;io_count[1]=0;vram_count[0]=0;vram_count[1]=0;');
tb=tb.replace('hold1=1;','hold1=1;run_vdp=0;vdpsnap=vdpr[0];');
tb=tb.replace('@(negedge clk);restore=1;','@(negedge clk);restore=1;vset=1;').replace('@(negedge clk);restore=0;','@(negedge clk);restore=0;vset=0;');
tb=tb.replace('compare(0);','compare(0);run_vdp=1;');
tb=tb.replace('repeat(8)@(negedge clk);reset_n=1;','repeat(8)@(negedge clk);reset_n=1;vdpsnap=0;initVDP=1;vset=1;repeat(2)@(negedge clk);vset=0;initVDP=0;');
tb=tb.replace('if(io_first_bad>=0)failed=1;',`if(io_first_bad>=0)failed=1;
 if(vram_count[0]!=vram_count[1])failed=1;
 for(integer j=0;j<vram_count[0]&&j<vram_count[1];j++)begin if($isunknown(vram_events[0][j])||$isunknown(vram_events[1][j]))$fatal(1,"unknown VRAM transaction"); if(vram_events[0][j]!==vram_events[1][j])failed=1;end
 $display("VRAM actual_writes=%0d/%0d first=%h/%h second=%h/%h",vram_count[0],vram_count[1],vram_events[0][0],vram_events[1][0],vram_events[0][1],vram_events[1][1]);`);
tb=tb.replace('reg run_vdp=1;','reg dma_we=0;reg [14:0] dma_a=0;\n reg run_vdp=1;');
tb=tb.replace('.reset_n(reset_n)','.reset_n(reset_n&&(v==0||!reset_dut))');
tb=tb.replace(".ss_vram_en(1'b0)",'.ss_vram_en(dma_we)').replace(".ss_vram_WE(1'b0)",'.ss_vram_WE(dma_we&&(v==1||initVDP))').replace(".ss_vram_WA(15'd0)",'.ss_vram_WA(dma_a)');
tb=tb.replace('repeat(2)@(negedge clk);vset=0;initVDP=0;',`repeat(2)@(negedge clk);
 if(PRELOAD!=0)begin dma_we=1;for(integer da=0;da<16384;da++)begin dma_a=da;@(negedge clk);end dma_we=0;end
 vset=0;initVDP=0;`);
tb=tb.replace('if(PRELOAD==2)for(integer dirty=0;dirty<700;dirty++)tick(0,1);',`if(PRELOAD==2)begin
 for(integer dirty=0;dirty<700;dirty++)tick(0,1);
 dma_we=1;for(integer da=0;da<16384;da++)begin dma_a=da;@(negedge clk);end dma_we=0;
 end`);
tb=tb.replace('io_count[0]=0;io_count[1]=0;\n repeat(40)','io_count[0]=0;io_count[1]=0;vram_count[0]=0;vram_count[1]=0;\n repeat(40)');
fs.writeFileSync(p.join(d,'cpu_vdp_tb.sv'),tb);
