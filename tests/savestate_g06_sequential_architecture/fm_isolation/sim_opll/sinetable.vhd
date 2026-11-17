



































library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_signed.all;

entity interpolate_mul is
    port (
        i0      : in    std_logic_vector(  8 downto 0 );    
        i1      : in    std_logic_vector( 11 downto 0 );    
        o       : buffer   std_logic_vector( 13 downto 0 )     
    );
end interpolate_mul;

architecture rtl of interpolate_mul is
    signal w_mul    : std_logic_vector( 21 downto 0 );      
begin

    w_mul   <= ('0' & i0) * i1;
    o       <= w_mul( 20 downto 7 );        
end rtl;


library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;                           

use ieee.std_logic_arith.conv_std_logic_vector;
entity SineTable is
    port (
        clk     : in    std_logic;
        clkena  : in    std_logic;
        wf      : in    std_logic;
        addr    : in    std_logic_vector( 17 downto 0 );    
        data    : buffer   std_logic_vector( 13 downto 0 )     
    ;
        
        ss_hold : in std_logic := '0';
        ss_addr : in std_logic_vector(7 downto 0) := (others=>'0');
        ss_read : in std_logic := '0';
        ss_write : in std_logic := '0';
        ss_wdata : in std_logic_vector(31 downto 0) := (others=>'0');
        ss_rdata : out std_logic_vector(31 downto 0);
        ss_initialized : out std_logic
);
end SineTable;

architecture rtl of sinetable is

    component interpolate_mul
        port (
            i0      : in    std_logic_vector(  8 downto 0 );    
            i1      : in    std_logic_vector( 11 downto 0 );    
            o       : buffer   std_logic_vector( 13 downto 0 )     
        );
    end component;

    type sin_type is array (0 to 127) of std_logic_vector( 10 downto 0 );  
    constant sin_data : sin_type := (
        "11111111111", "11001010000", "10101010001", "10010111100",
        "10001010011", "10000000001", "01110111110", "01110000101",
        "01101010101", "01100101001", "01100000011", "01011100000",
        "01011000000", "01010100011", "01010001000", "01001101111",
        "01001011000", "01001000010", "01000101101", "01000011010",
        "01000000111", "00111110110", "00111100101", "00111010101",
        "00111000110", "00110110111", "00110101001", "00110011100",
        "00110001111", "00110000011", "00101110111", "00101101011",
        "00101100000", "00101010110", "00101001011", "00101000001",
        "00100111000", "00100101110", "00100100101", "00100011100",
        "00100010100", "00100001011", "00100000011", "00011111011",
        "00011110100", "00011101100", "00011100101", "00011011110",
        "00011010111", "00011010001", "00011001010", "00011000100",
        "00010111110", "00010111000", "00010110010", "00010101100",
        "00010100111", "00010100001", "00010011100", "00010010111",
        "00010010010", "00010001101", "00010001000", "00010000011",
        "00001111111", "00001111010", "00001110110", "00001110010",
        "00001101110", "00001101010", "00001100110", "00001100010",
        "00001011110", "00001011010", "00001010111", "00001010011",
        "00001010000", "00001001101", "00001001001", "00001000110",
        "00001000011", "00001000000", "00000111101", "00000111011",
        "00000111000", "00000110101", "00000110011", "00000110000",
        "00000101110", "00000101011", "00000101001", "00000100111",
        "00000100101", "00000100010", "00000100000", "00000011110",
        "00000011101", "00000011011", "00000011001", "00000010111",
        "00000010110", "00000010100", "00000010011", "00000010001",
        "00000010000", "00000001110", "00000001101", "00000001100",
        "00000001011", "00000001010", "00000001001", "00000001000",
        "00000000111", "00000000110", "00000000101", "00000000100",
        "00000000011", "00000000011", "00000000010", "00000000010",
        "00000000001", "00000000001", "00000000000", "00000000000",
        "00000000000", "00000000000", "00000000000", "00000000000"
    );

    signal ff_data0     : std_logic_vector( 10 downto 0 );  
    signal ff_data1     : std_logic_vector( 10 downto 0 );  
    signal w_wf         : std_logic_vector( 13 downto 0 );
    signal w_xor        : std_logic_vector(  6 downto 0 );
    signal w_addr0      : std_logic_vector(  6 downto 0 );
    signal w_addr1      : std_logic_vector(  6 downto 0 );
    signal w_xaddr      : std_logic_vector(  6 downto 0 );
    signal ff_sign      : std_logic;
    signal ff_wf        : std_logic;
    signal ff_weight    : std_logic_vector(  8 downto 0 );
    signal w_sub        : std_logic_vector( 11 downto 0 );  
    signal w_mul        : std_logic_vector( 13 downto 0 );  
    signal w_inter      : std_logic_vector( 13 downto 0 );
    signal ff_data      : std_logic_vector( 13 downto 0 );
    signal ss_local_data : std_logic_vector(31 downto 0) := (others=>'0');

begin

    w_xor   <= (others => addr(16));
    w_xaddr <= addr( 15 downto 9 ) xor w_xor;
    w_addr0 <= w_xaddr;
    w_addr1 <= "1111111" xor w_xor when(addr( 15 downto 9 ) = "1111111" )else   
               (addr( 15 downto 9 ) + 1) xor w_xor;

    
    process(clk)

    

    

    
variable ss_v_ff_data0 : std_logic_vector(10 downto 0);
variable ss_v_ff_data1 : std_logic_vector(10 downto 0);
variable ss_v_ff_sign : std_logic_vector(0 downto 0);
variable ss_v_ff_wf : std_logic_vector(0 downto 0);
variable ss_v_ff_weight : std_logic_vector(8 downto 0);
variable ss_v_ff_data : std_logic_vector(13 downto 0);
variable ss_response : std_logic_vector(31 downto 0);
begin
if rising_edge(clk) then

ss_response := (others=>'0');
if ss_hold='1' and (ss_read='1' or ss_write='1') then
ss_v_ff_data0 := ff_data0;
ss_v_ff_data1 := ff_data1;
ss_v_ff_sign := (0 => ff_sign);
ss_v_ff_wf := (0 => ff_wf);
ss_v_ff_weight := ff_weight;
ss_v_ff_data := ff_data;

if ss_read='1' then
case conv_integer(ss_addr) is
when 98 =>
ss_response(10 downto 0) := ff_data0(10 downto 0);
ss_response(21 downto 11) := ff_data1(10 downto 0);
ss_response(22) := ff_sign;
ss_response(23) := ff_wf;
when 99 =>
ss_response(8 downto 0) := ff_weight(8 downto 0);
ss_response(22 downto 9) := ff_data(13 downto 0);
when others => null; end case;
end if;
if ss_write='1' then
case conv_integer(ss_addr) is
when 98 =>
ss_v_ff_data0(10 downto 0) := ss_wdata(10 downto 0);
ff_data0 <= ss_v_ff_data0;
ss_v_ff_data1(10 downto 0) := ss_wdata(21 downto 11);
ff_data1 <= ss_v_ff_data1;
ss_v_ff_sign(0) := ss_wdata(22);
ff_sign <= ss_v_ff_sign(0);
ss_v_ff_wf(0) := ss_wdata(23);
ff_wf <= ss_v_ff_wf(0);
when 99 =>
ss_v_ff_weight(8 downto 0) := ss_wdata(8 downto 0);
ff_weight <= ss_v_ff_weight;
ss_v_ff_data(13 downto 0) := ss_wdata(22 downto 9);
ff_data <= ss_v_ff_data;
when others => null; end case;
end if;
end if;
ss_local_data <= ss_response;

if ss_hold='0' then

            if( clkena = '1' )then
                ff_data0 <= sin_data( conv_integer( w_addr0 ) );
                ff_data1 <= sin_data( conv_integer( w_addr1 ) );
            end if;
        

            if( clkena = '1' )then
                ff_sign     <= addr(17);
                ff_wf       <= wf and addr(17);
                ff_weight   <= addr( 8 downto 0 );
            end if;
        

            if( clkena = '1' )then
                
                ff_data <= (ff_sign & w_inter(12 downto 0)) or w_wf;
            end if;
        

end if;
end if;
end process;


    
    

    
    
    w_sub   <= ('0' & ff_data1) - ('0' & ff_data0);

    u_interpolate_mul: interpolate_mul
    port map (
        i0      => ff_weight,
        i1      => w_sub,
        o       => w_mul
    );

    
    w_inter <= (ff_data0 & "00") + w_mul;   
    w_wf    <= (others => ff_wf);

    

    data <= ff_data;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
ss_rdata <= ss_local_data;
ss_initialized <= '1';

end rtl;
