




































library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_signed.all;

entity attack_table_mul is
    port(
        i0      : in    std_logic_vector(  7 downto 0 );    
        i1      : in    std_logic_vector(  7 downto 0 );    
        o       : buffer   std_logic_vector( 13 downto 0 )     
    );
end attack_table_mul;

architecture rtl of attack_table_mul is
    signal w_mul    : std_logic_vector( 16 downto 0 );
begin

    w_mul   <= ('0' & i0) * i1;
    o       <= w_mul( 15 downto 2 );        
end rtl;


library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith;

use ieee.std_logic_arith.conv_std_logic_vector;
entity AttackTable is
    port(
        clk     : in    std_logic;
        clkena  : in    std_logic;
        addr    : in    std_logic_vector( 21 downto 0 );    
        data    : buffer   std_logic_vector( 12 downto 0 )     
    ;
        
        ss_hold : in std_logic := '0';
        ss_addr : in std_logic_vector(7 downto 0) := (others=>'0');
        ss_read : in std_logic := '0';
        ss_write : in std_logic := '0';
        ss_wdata : in std_logic_vector(31 downto 0) := (others=>'0');
        ss_rdata : out std_logic_vector(31 downto 0);
        ss_initialized : out std_logic
);
end AttackTable;

architecture rtl of attacktable is

    component attack_table_mul
        port(
            i0      : in    std_logic_vector(  7 downto 0 );    
            i1      : in    std_logic_vector(  7 downto 0 );    
            o       : buffer   std_logic_vector( 13 downto 0 )     
        );
    end component;

    type ar_adjust_array is array ( 0 to 127 ) of std_logic_vector( 6 downto 0 );
    constant ar_adjust : ar_adjust_array :=(
        "0000000", "0000000", "0000000", "0000000", "0000000", "0000001", "0000001", "0000001",
        "0000001", "0000001", "0000010", "0000010", "0000010", "0000010", "0000011", "0000011",
        "0000011", "0000011", "0000100", "0000100", "0000100", "0000100", "0000100", "0000101",
        "0000101", "0000101", "0000110", "0000110", "0000110", "0000110", "0000111", "0000111",
        "0000111", "0000111", "0001000", "0001000", "0001000", "0001001", "0001001", "0001001",
        "0001001", "0001010", "0001010", "0001010", "0001011", "0001011", "0001011", "0001100",
        "0001100", "0001100", "0001101", "0001101", "0001101", "0001110", "0001110", "0001110",
        "0001111", "0001111", "0001111", "0010000", "0010000", "0010001", "0010001", "0010001",
        "0010010", "0010010", "0010011", "0010011", "0010100", "0010100", "0010101", "0010101",
        "0010101", "0010110", "0010110", "0010111", "0010111", "0011000", "0011000", "0011001",
        "0011010", "0011010", "0011011", "0011011", "0011100", "0011101", "0011101", "0011110",
        "0011110", "0011111", "0100000", "0100001", "0100001", "0100010", "0100011", "0100100",
        "0100100", "0100101", "0100110", "0100111", "0101000", "0101001", "0101010", "0101011",
        "0101100", "0101101", "0101111", "0110000", "0110001", "0110011", "0110100", "0110110",
        "0111000", "0111001", "0111011", "0111101", "1000000", "1000010", "1000101", "1001000",
        "1001011", "1010000", "1010100", "1011010", "1100010", "1101100", "1110101", "1111111"
    );

    signal ff_w     : std_logic_vector(  7 downto 0 );
    signal ff_d1    : std_logic_vector(  6 downto 0 );
    signal ff_d2    : std_logic_vector(  6 downto 0 );

    signal w_addr1  : std_logic_vector(  6 downto 0 );
    signal w_addr2  : std_logic_vector(  6 downto 0 );
    signal w_sub    : std_logic_vector(  7 downto 0 );  
    signal w_mul    : std_logic_vector( 13 downto 0 );  
    signal w_inter  : std_logic_vector( 13 downto 0 );
    signal ss_local_data : std_logic_vector(31 downto 0) := (others=>'0');

begin

    w_addr1 <= addr( 21 downto 15 );
    w_addr2 <= (others => '1') when( addr( 21 downto 15 ) = "1111111" )else
               w_addr1 + 1;

    process(clk)

    

    

    
variable ss_v_ff_w : std_logic_vector(7 downto 0);
variable ss_v_ff_d1 : std_logic_vector(6 downto 0);
variable ss_v_ff_d2 : std_logic_vector(6 downto 0);
variable ss_v_data : std_logic_vector(12 downto 0);
variable ss_response : std_logic_vector(31 downto 0);
begin
if rising_edge(clk) then

ss_response := (others=>'0');
if ss_hold='1' and (ss_read='1' or ss_write='1') then
ss_v_ff_w := ff_w;
ss_v_ff_d1 := ff_d1;
ss_v_ff_d2 := ff_d2;
ss_v_data := data;

if ss_read='1' then
case conv_integer(ss_addr) is
when 91 =>
ss_response(7 downto 0) := ff_w(7 downto 0);
ss_response(14 downto 8) := ff_d1(6 downto 0);
ss_response(21 downto 15) := ff_d2(6 downto 0);
when 92 =>
ss_response(12 downto 0) := data(12 downto 0);
when others => null; end case;
end if;
if ss_write='1' then
case conv_integer(ss_addr) is
when 91 =>
ss_v_ff_w(7 downto 0) := ss_wdata(7 downto 0);
ff_w <= ss_v_ff_w;
ss_v_ff_d1(6 downto 0) := ss_wdata(14 downto 8);
ff_d1 <= ss_v_ff_d1;
ss_v_ff_d2(6 downto 0) := ss_wdata(21 downto 15);
ff_d2 <= ss_v_ff_d2;
when 92 =>
ss_v_data(12 downto 0) := ss_wdata(12 downto 0);
data <= ss_v_data;
when others => null; end case;
end if;
end if;
ss_local_data <= ss_response;

if ss_hold='0' then

            if( clkena = '1' )then
                ff_d1 <= ar_adjust( conv_integer( w_addr1 ) );
                ff_d2 <= ar_adjust( conv_integer( w_addr2 ) );
            end if;
        

            if( clkena = '1' )then
                ff_w <= addr( 14 downto 7 );    
            end if;
        

            if( clkena = '1' )then
                data <=w_inter( 12 downto 0 );  
            end if;
        

end if;
end if;
end process;


    

    
    
    w_sub   <= ('0' & ff_d2) - ('0' & ff_d1);

    u_attack_table_mul: attack_table_mul
    port map (
        i0      => ff_w,
        i1      => w_sub,
        o       => w_mul
    );

    w_inter <= ('0' & ff_d1 & "000000") + w_mul;

    

ss_rdata <= ss_local_data;
ss_initialized <= '1';

end rtl;
