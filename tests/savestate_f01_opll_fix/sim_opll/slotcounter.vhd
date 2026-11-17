


































library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

use ieee.std_logic_arith.conv_std_logic_vector;
entity SlotCounter is
    generic (
        delay   : integer
    );
    port (
        clk     : in    std_logic;
        reset   : in    std_logic;
        clkena  : in    std_logic;

        slot    : buffer   std_logic_vector( 4 downto 0 );
        stage   : buffer   std_logic_vector( 1 downto 0 )
    ;
        
        ss_hold : in std_logic := '0';
        ss_addr : in std_logic_vector(7 downto 0) := (others=>'0');
        ss_read : in std_logic := '0';
        ss_write : in std_logic := '0';
        ss_wdata : in std_logic_vector(31 downto 0) := (others=>'0');
        ss_rdata : out std_logic_vector(31 downto 0);
        ss_initialized : out std_logic
);
end SlotCounter;

architecture rtl of SlotCounter is
    signal ff_count     : std_logic_vector( 6 downto 0 );
    signal ss_local_data : std_logic_vector(31 downto 0) := (others=>'0');

begin

    process(clk,reset)

    
variable ss_v_ff_count : std_logic_vector(6 downto 0);
variable ss_response : std_logic_vector(31 downto 0);
begin
if reset='1' then
ss_local_data <= (others=>'0');

            ff_count <= "1000111" - delay;
        
elsif rising_edge(clk) then

ss_response := (others=>'0');
if ss_hold='1' and (ss_read='1' or ss_write='1') then
ss_v_ff_count := ff_count;

if ss_read='1' then
case conv_integer(ss_addr) is
when 78 => if delay=0 then ss_response(6 downto 0):=ff_count; end if;
when others => null; end case;
end if;
if ss_write='1' then
case conv_integer(ss_addr) is
when 78 => if conv_integer(ss_wdata(6 downto 0)) >= delay then ff_count <= conv_std_logic_vector(conv_integer(ss_wdata(6 downto 0))-delay,7); else ff_count <= conv_std_logic_vector(conv_integer(ss_wdata(6 downto 0))+72-delay,7); end if;
when others => null; end case;
end if;
end if;
ss_local_data <= ss_response;

if ss_hold='0' then

            if( clkena ='1' )then
                if( ff_count = "1000111" )then      
                    ff_count <= (others => '0');
                else
                    ff_count <= ff_count + 1;
                end if;
            end if;
        

end if;
end if;
end process;


    stage   <= ff_count( 1 downto 0 );      
    slot    <= ff_count( 6 downto 2 );      
ss_rdata <= ss_local_data;
ss_initialized <= '1';

end rtl;
