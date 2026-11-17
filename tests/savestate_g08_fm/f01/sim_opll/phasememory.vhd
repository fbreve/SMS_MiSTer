





























library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.VM2413.ALL;

use ieee.std_logic_arith.conv_std_logic_vector;
entity PhaseMemory is
  port (
    clk     : in std_logic;
    reset   : in std_logic;
    slot    : in SLOT_TYPE;
    memwr   : in std_logic;
    memout  : buffer PHASE_TYPE;
    memin   : in  PHASE_TYPE
  ;
        
        ss_hold : in std_logic := '0';
        ss_addr : in std_logic_vector(7 downto 0) := (others=>'0');
        ss_read : in std_logic := '0';
        ss_write : in std_logic := '0';
        ss_wdata : in std_logic_vector(31 downto 0) := (others=>'0');
        ss_rdata : out std_logic_vector(31 downto 0);
        ss_initialized : out std_logic
);
end PhaseMemory;

architecture RTL of PhaseMemory is

  type PHASE_ARRAY_TYPE is array (0 to 18-1) of PHASE_TYPE;
  signal phase_array : PHASE_ARRAY_TYPE;
  attribute ramstyle : string;
  attribute ramstyle of phase_array : signal is "logic";

    signal ss_local_data : std_logic_vector(31 downto 0) := (others=>'0');
    signal ss_mem_active : std_logic;
    signal ss_mem_index : integer range 0 to 17;
    signal ss_mem_ready : std_logic := '0';
    signal ss_mem_vector : std_logic_vector(17 downto 0);

begin

  process(clk, reset)

    variable init_slot : integer range 0 to 18;

  begin

   if reset = '1' then
ss_mem_ready <= '0';

      init_slot := 0;

   elsif rising_edge(clk) then

     ss_mem_ready <= '0'; if init_slot=18 then ss_mem_ready <= '1'; end if;
if ss_hold='0' then
if init_slot /= 18 then

       phase_array(init_slot) <= (others=>'0');
       init_slot := init_slot + 1;

     elsif memwr = '1' then

         phase_array(conv_integer(slot)) <= memin;

     end if;

     
elsif ss_write='1' and ss_mem_active='1' then
phase_array(ss_mem_index)<=ss_wdata(17 downto 0);
end if;
if ss_mem_active='1' then memout <= phase_array(ss_mem_index); else memout <= phase_array(conv_integer(slot)); end if;

    end if;

  end process;
ss_mem_active <= '1' when ss_hold='1' and conv_integer(ss_addr)>=13 and conv_integer(ss_addr)<=30 else '0';
ss_mem_index <= conv_integer(ss_addr)-13 when conv_integer(ss_addr)>=13 and conv_integer(ss_addr)<=30 else 0;
ss_mem_vector <= memout;
ss_local_data <= (13 downto 0 => '0') & ss_mem_vector when ss_mem_active='1' else (others=>'0');


ss_rdata <= ss_local_data;
ss_initialized <= ss_mem_ready;

end rtl;
