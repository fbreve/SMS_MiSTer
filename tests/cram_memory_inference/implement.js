// Invoked only after pre_edit_gate.json binds passing component/capture proof.
const fs=require('fs'),assert=require('assert'),crypto=require('crypto'),d=__dirname;
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const gate=JSON.parse(fs.readFileSync(d+'/pre_edit_gate.json','utf8'));assert(gate.passed);
for(const x of gate.production)assert.equal(sha(fs.readFileSync(x.file)),x.sha256,x.file);
function edit(p,fn){let s=fs.readFileSync(p,'utf8'),t=fn(s);assert.notEqual(s,t,p);fs.writeFileSync(p,t);}
function one(s,a,b){assert(s.includes(a),'missing '+a);assert.equal(s.split(a).length,2,'ambiguous '+a);return s.replace(a,b);}
let candidate=fs.readFileSync(d+'/vdp_cram_candidate.vhd','utf8').replace(/\bvdp_cram_candidate\b/g,'vdp_cram');
fs.writeFileSync('rtl/vdp_cram.vhd',candidate);
edit('rtl/vdp.vhd',s=>{
 s=one(s,'-- CRAM snapshot (32 × 12 bits = 384 bits, combinational)','-- CRAM snapshot: registered 12-bit reads while the guest is frozen');
 s=one(s,'ss_cram_out    : out STD_LOGIC_VECTOR(383 downto 0);','ss_cram_out    : out STD_LOGIC_VECTOR(11 downto 0);\n        ss_cram_read   : in STD_LOGIC := \'0\';');
 s=one(s,'ss_D             => ss_cram_out,','ss_Q             => ss_cram_out,\n        ss_rd            => ss_cram_read,');
 for(const line of ['\t\t-- CRAM snapshot: registered 12-bit reads while the guest is frozen',"        ss_cram_read   : in STD_LOGIC := '0';",'        ss_rd            => ss_cram_read,'])s=s.replace(line+'\r\n',line+'\n');return s;
});
edit('rtl/system.vhd',s=>{
 s=one(s,'vdp_cram_out : out STD_LOGIC_VECTOR(383 downto 0);','vdp_cram_out : out STD_LOGIC_VECTOR(11 downto 0);\n        ss_cram_read : in STD_LOGIC := \'0\';');
 s=one(s,'vdp2_cram_out : out STD_LOGIC_VECTOR(383 downto 0);','vdp2_cram_out : out STD_LOGIC_VECTOR(11 downto 0);');
 s=one(s,'signal vdp2_cram_out_i   : std_logic_vector(383 downto 0);','signal vdp2_cram_out_i   : std_logic_vector(11 downto 0);');
 s=one(s,'ss_cram_out => vdp_cram_out,','ss_cram_out => vdp_cram_out,\n        ss_cram_read => ss_cram_read,');
 s=one(s,'ss_cram_out => vdp2_cram_out_i,','ss_cram_out => vdp2_cram_out_i,\n        ss_cram_read => ss_cram_read,');return s;
});
edit('SMS.sv',s=>{
 s=one(s,'wire [383:0] ss_vdp_cram;','wire [11:0] ss_vdp_cram;\nwire ss_cram_read;');
 s=one(s,'wire [383:0] ss_vdp2_cram;','wire [11:0] ss_vdp2_cram;');
 s=one(s,'.vdp_cram_out(ss_vdp_cram),','.vdp_cram_out(ss_vdp_cram),\n    .ss_cram_read(ss_cram_read),');
 s=one(s,'.cram_out        (ss_vdp_cram),','.cram_out        (ss_vdp_cram),\n    .cram_read       (ss_cram_read),');return s;
});
edit('rtl/savestates.sv',s=>{
 s=one(s,'input     [383:0] cram_out,','input      [11:0] cram_out,\n    output cram_read,');
 s=one(s,'input     [383:0] cram2_out,','input      [11:0] cram2_out,');
 s=one(s,'reg [6:0]  state;','reg [6:0]  state;\nlocalparam ST_CRAM_SCAN_WAIT=7\'d122, ST_CRAM_SCAN_COLLECT=7\'d123;\nassign cram_read = state==ST_CRAM_SCAN_WAIT || state==ST_CRAM_SCAN_COLLECT;');
 s=one(s,'            cram_snap   <= cram_out;','            // Palette capture uses the synchronous entry scan below.');
 s=one(s,'                cram2_snap  <= cram2_out;','                // The second palette is scanned in parallel while held.');
 s=one(s,'            freeze_drain_cnt <= 0;\n            state            <= ST_FREEZE_DRAIN;','            freeze_drain_cnt <= 0;\n            // Legacy64 System E retains the live secondary palette.\n            if (do_save || systeme) begin\n                cram_entry<=0;cram_A<=0;cram2_A<=0;\n                state<=ST_CRAM_SCAN_WAIT;\n            end else state<=ST_FREEZE_DRAIN;');
 s=one(s,'        ST_FREEZE_DRAIN: begin',`        // Read latency is one clock. Collect the prior registered read,
        // then issue the next entry. No guest palette writer runs here.
        ST_CRAM_SCAN_WAIT: state<=ST_CRAM_SCAN_COLLECT;
        ST_CRAM_SCAN_COLLECT: begin
            cram_snap<={cram_out,cram_snap[383:12]};
            if(systeme)cram2_snap<={cram2_out,cram2_snap[383:12]};
            if(cram_entry==31) begin
                cram_entry<=0;state<=ST_FREEZE_DRAIN;
            end else begin
                cram_entry<=cram_entry+5'd1;
                cram_A<=cram_entry+5'd1;cram2_A<=cram_entry+5'd1;
                state<=ST_CRAM_SCAN_WAIT;
            end
        end
        ST_FREEZE_DRAIN: begin`);return s;
});
const files=['SMS.sv','rtl/system.vhd','rtl/vdp.vhd','rtl/vdp_cram.vhd','rtl/savestates.sv'];
fs.writeFileSync(d+'/candidate_sources.json',JSON.stringify(files.map(file=>({file,sha256:sha(fs.readFileSync(file))})),null,2));
console.log('Applied only CRAM memory and snapshot access changes in five files.');
