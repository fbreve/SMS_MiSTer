// Testbench-first proposal. This module writes only explicitly supplied files
// in this test tree; it never edits production RTL.
const fields=[['tile_index',9],['x',8],['tile_y',3],['palette',1],['palette_shift',1],['priority_latch',1],['flip_x',1],['datac',8],['data0',8],['data1',8],['data2',8],['data3',8],['shift0',8],['shift1',8],['shift2',8],['shift3',8],['text_shift',6],['text_tile_index',8],['text_pattern_hi',6],['text_position',8],['vram_address',14],['priority_output',1]];
let top=138;for(const a of fields){a.push(top,top-a[1]+1);top-=a[1];}if(top!==-1)throw Error('width');
const span=n=>{let f=fields.find(f=>f[0]===n);return f[1]===1?'ss_bg_in('+f[2]+')':'ss_bg_in('+f[2]+' downto '+f[3]+')';};
function proposal(s){
 s=s.replace(/\r\n/g,'\n');
 s=s.replace(/port\s*\(/i,`port (
 ss_bg_out: out std_logic_vector(138 downto 0);
 ss_bg_in: in std_logic_vector(138 downto 0) := (others=>'0');
 ss_bg_valid: in std_logic := '0';`);
 // Internal aliases satisfy Quartus' pre-VHDL2008 output-read restriction.
 s=s.replace(/architecture rtl of vdp_background is/,`architecture rtl of vdp_background is
 signal bg_vram_address: std_logic_vector(13 downto 0);
 signal bg_priority: std_logic;
 signal text_position: std_logic_vector(7 downto 0);`);
 s=s.replace(/\bvram_A\s*<=/g,'bg_vram_address <=').replace(/\bpriority\s*<=/g,'bg_priority <=');
 s=s.replace(/begin\s*\n/,`begin
 vram_A <= bg_vram_address;
 priority <= bg_priority;
 text_position <= conv_std_logic_vector(conv_integer(text_column)*6+conv_integer(text_phase),8);
 ss_bg_out <= tile_index & x & tile_y & palette & palette_shift & priority_latch & flip_x & datac & data0 & data1 & data2 & data3 & shift0 & shift1 & shift2 & shift3 & text_shift & text_tile_index & text_pattern(7 downto 2) & text_position & bg_vram_address & bg_priority;
`);
 // Restore priority applies at the existing ss_restore; no enabled guest tick.
 s=s.replace(/if ss_restore = '1' then[\s\S]*?elsif ce_pix = '1' then/,`if ss_restore = '1' then
                if ss_bg_valid='1' then x <= ${span('x')};
                else x <= (others=>'0'); end if;
            elsif ce_pix = '1' then`);
 s=s.replace(/text_phase\s*<= \(others=>'0'\);\s*\n\s*text_column <= \(others=>'0'\);/,`if ss_bg_valid='1' then
                    text_phase <= conv_std_logic_vector(conv_integer(${span('text_position')}) mod 6,3);
                    text_column <= conv_std_logic_vector(conv_integer(${span('text_position')}) / 6,6);
                else
                    text_phase <= (others=>'0'); text_column <= (others=>'0');
                end if;`);
 // The registered fetch address also holds through transport. RAM output
 // refills from it during the existing settle/phase-commit interval.
 s=s.replace("if ce_pix = '1' then\n\t\t\t\tsx :=",`if ss_restore='1' then
                if ss_bg_valid='1' then bg_vram_address <= ${span('vram_address')};
                else bg_vram_address <= (others=>'0'); end if;
            elsif ce_pix = '1' then
                sx :=`);
 const data=['text_tile_index','tile_index','flip_x','tile_y','palette','priority_latch','data0','data1','data2','data3','datac'];
 const old=s.match(/if ss_restore = '1' then\s*\n\s*text_tile_index[\s\S]*?elsif ce_pix = '1' then/);if(!old)throw Error('data restore anchor');
 s=s.replace(old[0],`if ss_restore = '1' then
                if ss_bg_valid='1' then
${data.map(n=>'                    '+n+' <= '+span(n)+';').join('\n')}
                    text_pattern <= ${span('text_pattern_hi')} & "00";
                else
${data.map(n=>'                    '+n+' <= '+(fields.find(f=>f[0]===n)[1]===1?"'0'":"(others=>'0')")+';').join('\n')}
                    text_pattern <= (others=>'0');
                end if;
            elsif ce_pix = '1' then`);
 const shifts=['text_shift','shift0','shift1','shift2','shift3','palette_shift'];
 const oldShift=s.match(/if ss_restore = '1' then\s*\n\s*text_shift[\s\S]*?elsif ce_pix = '1' then/);if(!oldShift)throw Error('shift restore anchor');
 s=s.replace(oldShift[0],`if ss_restore = '1' then
                if ss_bg_valid='1' then
${shifts.map(n=>'                    '+n+' <= '+span(n)+';').join('\n')}
                    bg_priority <= ${span('priority_output')};
                else
${shifts.map(n=>'                    '+n+' <= '+(n==='palette_shift'?"'0'":"(others=>'0')")+';').join('\n')}
                    bg_priority <= '0';
                end if;
            elsif ce_pix = '1' then`);
 return s;
}
module.exports={fields,span,proposal,width:139};
