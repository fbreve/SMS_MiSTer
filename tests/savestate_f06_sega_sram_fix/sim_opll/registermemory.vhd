


































library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

use ieee.std_logic_arith.conv_std_logic_vector;
entity RegisterMemory is
    port (
        clk     : in    std_logic;
        reset   : in    std_logic;
        addr    : in    std_logic_vector(  3 downto 0 );
        wr      : in    std_logic;
        idata   : in    std_logic_vector( 23 downto 0 );
        odata   : buffer   std_logic_vector( 23 downto 0 )
    ;
        
        ss_hold : in std_logic := '0';
        ss_addr : in std_logic_vector(7 downto 0) := (others=>'0');
        ss_read : in std_logic := '0';
        ss_write : in std_logic := '0';
        ss_wdata : in std_logic_vector(31 downto 0) := (others=>'0');
        ss_rdata : out std_logic_vector(31 downto 0);
        ss_initialized : out std_logic
);
end RegisterMemory;

architecture rtl of registermemory is
    
    type regs_array_type is array (0 to 8) of std_logic_vector( 23 downto 0 );
    signal regs_array : regs_array_type;
    attribute ramstyle : string;
    attribute ramstyle of regs_array : signal is "logic";

    signal ss_local_data : std_logic_vector(31 downto 0) := (others=>'0');
    signal ss_mem_active : std_logic;
    signal ss_mem_index : integer range 0 to 8;
    signal ss_mem_ready : std_logic := '0';
    signal ss_mem_vector : std_logic_vector(23 downto 0);

begin
    process( reset, clk )
        variable init_state : integer range 0 to 9;
    begin
        if( reset = '1' )then
ss_mem_ready <= '0';
            init_state := 0;
        elsif rising_edge(clk) then
            ss_mem_ready <= '0'; if init_state=9 then ss_mem_ready <= '1'; end if;
if ss_hold='0' then
if( init_state /= 9 )then
                
                regs_array( init_state ) <= (others => '0');
                init_state := init_state + 1;
            elsif( wr = '1' )then
                
                regs_array( conv_integer(addr) ) <= idata;
            end if;
            
            
elsif ss_write='1' and ss_mem_active='1' then
regs_array(ss_mem_index)<=ss_wdata(21 downto 14) & "00" & ss_wdata(13 downto 0);
end if;
if ss_mem_active='1' then odata <= regs_array(ss_mem_index); else odata <= regs_array( conv_integer(addr) ); end if;
        end if;
    end process;
ss_mem_active <= '1' when ss_hold='1' and conv_integer(ss_addr)>=0 and conv_integer(ss_addr)<=8 else '0';
ss_mem_index <= conv_integer(ss_addr)-0 when conv_integer(ss_addr)>=0 and conv_integer(ss_addr)<=8 else 0;
ss_mem_vector <= odata;
ss_local_data <= (9 downto 0 => '0') & ss_mem_vector(23 downto 16) & ss_mem_vector(13 downto 0) when ss_mem_active='1' else (others=>'0');

ss_rdata <= ss_local_data;
ss_initialized <= ss_mem_ready;

end rtl;
