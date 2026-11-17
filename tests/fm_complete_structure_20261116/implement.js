const fs=require('fs'),p=require('path'),assert=require('assert');const f=p.join(__dirname,'worktree/rtl/VM2413/slotcounter.vhd');let s=fs.readFileSync(f,'latin1');const old="when 78 => if conv_integer(ss_wdata(6 downto 0)) >= delay then ff_count <= conv_std_logic_vector(conv_integer(ss_wdata(6 downto 0))-delay,7); else ff_count <= conv_std_logic_vector(conv_integer(ss_wdata(6 downto 0))+72-delay,7); end if;";assert(s.includes(old));s=s.replace('variable ss_v_ff_count :','-- Select the constant before one bounded adder; preserve modulo-128 bus semantics.\nvariable ss_restore_offset : std_logic_vector(6 downto 0);\nvariable ss_v_ff_count :').replace(old,`when 78 =>
if conv_integer(ss_wdata(6 downto 0)) >= delay then
    ss_restore_offset := conv_std_logic_vector((128-delay) mod 128,7);
else
    ss_restore_offset := conv_std_logic_vector(72-delay,7);
end if;
ff_count <= ss_wdata(6 downto 0) + ss_restore_offset;`);fs.writeFileSync(f,s,'latin1');
