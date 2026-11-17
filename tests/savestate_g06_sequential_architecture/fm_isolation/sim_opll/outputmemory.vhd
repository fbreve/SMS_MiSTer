





























library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.VM2413.ALL;

use ieee.std_logic_arith.conv_std_logic_vector;
entity OutputMemory is port (
  clk    : in std_logic;
  reset  : in std_logic;
  wr     : in std_logic;
  addr  : in SLOT_TYPE;
  wdata  : in SIGNED_LI_TYPE;
  rdata  : buffer SIGNED_LI_TYPE;
  addr2  : in SLOT_TYPE;
  rdata2 : buffer SIGNED_LI_TYPE
;
        
        ss_hold : in std_logic := '0';
        ss_addr : in std_logic_vector(7 downto 0) := (others=>'0');
        ss_read : in std_logic := '0';
        ss_write : in std_logic := '0';
        ss_wdata : in std_logic_vector(31 downto 0) := (others=>'0');
        ss_rdata : out std_logic_vector(31 downto 0);
        ss_initialized : out std_logic
);
end OutputMemory;

architecture RTL of OutputMemory is

  type SIGNED_LI_ARRAY_TYPE is array (0 to 18) of SIGNED_LI_VECTOR_TYPE;
  signal data_array : SIGNED_LI_ARRAY_TYPE;
  attribute ramstyle : string;
  attribute ramstyle of data_array : signal is "logic";

    signal ss_local_data : std_logic_vector(31 downto 0) := (others=>'0');
    signal ss_mem_active : std_logic;
    signal ss_mem_index : integer range 0 to 17;
    signal ss_mem_ready : std_logic := '0';
    signal ss_mem_vector : std_logic_vector(9 downto 0);

begin

  process(clk, reset)

    variable init_ch : integer range 0 to 18;

  begin

    if (reset = '1') then
ss_mem_ready <= '0';

      init_ch := 0;

    elsif rising_edge(clk) then

      ss_mem_ready <= '0'; if init_ch=18 then ss_mem_ready <= '1'; end if;
if ss_hold='0' then
if init_ch /= 18 then

        data_array(init_ch) <= (others=>'0');
        init_ch := init_ch + 1;

      elsif wr='1' then

        data_array(conv_integer(addr)) <= CONV_SIGNED_LI_VECTOR(wdata);

      end if;

      
elsif ss_write='1' and ss_mem_active='1' then
data_array(ss_mem_index)<=ss_wdata(9 downto 0);
end if;
if ss_mem_active='1' then rdata <= CONV_SIGNED_LI(data_array(ss_mem_index)); else rdata <= CONV_SIGNED_LI(data_array(conv_integer(addr))); end if;
      rdata2 <= CONV_SIGNED_LI(data_array(conv_integer(addr2)));

    end if;

  end process;
ss_mem_active <= '1' when ss_hold='1' and conv_integer(ss_addr)>=58 and conv_integer(ss_addr)<=75 else '0';
ss_mem_index <= conv_integer(ss_addr)-58 when conv_integer(ss_addr)>=58 and conv_integer(ss_addr)<=75 else 0;
ss_mem_vector <= CONV_SIGNED_LI_VECTOR(rdata);
ss_local_data <= (21 downto 0 => '0') & ss_mem_vector when ss_mem_active='1' else (others=>'0');


ss_rdata <= ss_local_data;
ss_initialized <= ss_mem_ready;

end rtl;
