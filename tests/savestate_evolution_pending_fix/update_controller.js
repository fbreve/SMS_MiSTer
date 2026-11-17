// One-time scoped production edit, retained for review; rejects reapplication.
const fs=require('fs'),path=require('path'),p=path.resolve(__dirname,'../../rtl/savestates.sv');let s=fs.readFileSync(p,'utf8');
if(s.includes('EVOLUTION_PENDING_MAGIC'))throw Error('Already updated');
s=s.replace('// v10: 02c contains exact Evolution selector/history [56:0], zero [63:57].\n// 02d validates width57 and owner "EV10". Legacy Evolution cannot reconstruct\n// this state and is rejected before any restore writes; other mappers retain\n// their v1-v9 compatibility paths. Pending Evolution operation state is F15.', '// v11: 02c keeps F14 selector/history [56:0], adds armed/read/menu [59:57],\n// and validates zero padding [63:60]. 02d validates width60 and owner "EV11".\n// Evolution v10 and earlier lack protocol phase and are rejected before any\n// restore writes; other mappers retain their v1-v10 compatibility paths.');
s=s.replace("localparam [63:0] EVOLUTION_HISTORY_DESC = 64'h0000003945563130;", "localparam [23:0] EVOLUTION_PENDING_MAGIC = 24'h48430b;\nlocalparam [63:0] EVOLUTION_HISTORY_DESC = 64'h0000003c45563131;");
s=s.replaceAll('dout_latch[63:40] == EVOLUTION_HISTORY_MAGIC', '(dout_latch[63:40] == EVOLUTION_HISTORY_MAGIC || dout_latch[63:40] == EVOLUTION_PENDING_MAGIC)');
s=s.replaceAll('dout_latch[63:40] != EVOLUTION_HISTORY_MAGIC','dout_latch[63:40] != EVOLUTION_PENDING_MAGIC');
s=s.replace('video_word = {EVOLUTION_HISTORY_MAGIC', 'video_word = {EVOLUTION_PENDING_MAGIC');
s=s.replaceAll("{7'd0,evolution_snap[152:96]}","{4'd0,evolution_snap[155:96]}");
s=s.replace("{7'd0,dout_latch[56:0]}","{4'd0,dout_latch[59:0]}").replace('evolution_history_valid <= dout_latch[63:57] == 0','evolution_history_valid <= dout_latch[63:60] == 0');
fs.writeFileSync(p,s);
