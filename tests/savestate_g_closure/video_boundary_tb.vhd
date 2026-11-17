library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity video_boundary_tb is end;
architecture test of video_boundary_tb is
 signal clk: std_logic := '0';
 signal ce, cs, rs: std_logic := '0';
 signal p,b,g,m1,m2,m3,dm1,dm2,dm3: std_logic := '0';
 signal rstate,dstate,initial: std_logic_vector(21 downto 0):=(others=>'0');
 signal rv,dv: std_logic_vector(7 downto 0);
 signal unused: std_logic_vector(8 downto 0);
begin
 clk <= not clk after 5 ns;
 refv: entity work.video port map(clk,ce,p,b,g,'0','0',m1,m2,m3,'1',rstate,initial,rs,open,open,rv,open,open,open,open);
 dutv: entity work.video port map(clk,ce,p,b,g,'0','0',dm1,dm2,dm3,'1',dstate,rstate,cs,open,open,dv,open,open,open,open);
 process
  variable checks,loads,h,v: integer:=0;
  procedure tick is begin wait until rising_edge(clk); wait for 1 ns; end;
 begin
  for cfg in 0 to 63 loop
   p<=std_logic(to_unsigned(cfg,6)(5)); b<=std_logic(to_unsigned(cfg,6)(4)); g<=std_logic(to_unsigned(cfg,6)(3));
   m1<=std_logic(to_unsigned(cfg,6)(2)); m2<=std_logic(to_unsigned(cfg,6)(1)); m3<=std_logic(to_unsigned(cfg,6)(0));
   dm1<=std_logic(to_unsigned(cfg,6)(2)); dm2<=std_logic(to_unsigned(cfg,6)(1)); dm3<=std_logic(to_unsigned(cfg,6)(0));
   ce<='0';rs<='1';tick;rs<='0';ce<='1';
   -- Natural progression from power-up counter values, beyond a complete frame.
   for k in 0 to 332799 loop
    tick;
    h:=to_integer(unsigned(rstate(21 downto 13)));v:=to_integer(unsigned(rstate(12 downto 4)));
    if h<=256 and rstate(0)='1' then
     assert rv=std_logic_vector(to_unsigned(v mod 256,8)) report "VCounter invariant" severity failure;
     checks:=checks+1;
     if h=0 or h=1 or h=254 or h=255 or h=256 then
      -- Restore while discarded mode is still visible on this edge.
      ce<='0';cs<='1';dm1<=not m1;dm2<=not m2;dm3<=not m3;tick;
      assert dv=rv and dstate=rstate report "accepted-window reconstruction" severity failure;
      cs<='0';dm1<=m1;dm2<=m2;dm3<=m3;tick;
      assert dv=rv report "settled mode reconstruction" severity failure;
      ce<='1';loads:=loads+1;
     end if;
    end if;
   end loop;
  end loop;
  report "PASS G07 configurations=64 invariant_checks=" & integer'image(checks) & " restore_checks=" & integer'image(loads);
  std.env.stop;
  wait;
 end process;
end;
