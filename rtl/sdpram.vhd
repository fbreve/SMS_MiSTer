LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

-- Simple dual-port RAM: port A writes, port B reads.
-- Intended for line buffers that are filled by DMA while video reads them.
ENTITY sdpram IS
 GENERIC
 (
  widthad_a : natural;
  width_a   : natural := 8;
  mixed_port_rdwr : string := "DONT_CARE"
 );
 PORT
 (
  address_a : IN STD_LOGIC_VECTOR(widthad_a-1 DOWNTO 0);
  address_b : IN STD_LOGIC_VECTOR(widthad_a-1 DOWNTO 0);
  clock     : IN STD_LOGIC;
  data_a    : IN STD_LOGIC_VECTOR(width_a-1 DOWNTO 0);
  wren_a    : IN STD_LOGIC;
  q_b       : OUT STD_LOGIC_VECTOR(width_a-1 DOWNTO 0)
 );
END sdpram;

ARCHITECTURE SYN OF sdpram IS
 COMPONENT altsyncram
  GENERIC (
   address_reg_b : STRING;
   clock_enable_input_a : STRING;
   clock_enable_input_b : STRING;
   clock_enable_output_b : STRING;
   init_file : STRING;
   intended_device_family : STRING;
   lpm_type : STRING;
   numwords_a : NATURAL;
   numwords_b : NATURAL;
   operation_mode : STRING;
   outdata_aclr_b : STRING;
   outdata_reg_b : STRING;
   power_up_uninitialized : STRING;
   read_during_write_mode_mixed_ports : STRING;
   widthad_a : NATURAL;
   widthad_b : NATURAL;
   width_a : NATURAL;
   width_b : NATURAL;
   width_byteena_a : NATURAL
  );
  PORT (
   wren_a : IN STD_LOGIC;
   clock0 : IN STD_LOGIC;
   address_a : IN STD_LOGIC_VECTOR(widthad_a-1 DOWNTO 0);
   address_b : IN STD_LOGIC_VECTOR(widthad_a-1 DOWNTO 0);
   q_b : OUT STD_LOGIC_VECTOR(width_a-1 DOWNTO 0);
   data_a : IN STD_LOGIC_VECTOR(width_a-1 DOWNTO 0)
  );
 END COMPONENT;
BEGIN
 altsyncram_component : altsyncram
  GENERIC MAP (
   address_reg_b => "CLOCK0",
   clock_enable_input_a => "BYPASS",
   clock_enable_input_b => "BYPASS",
   clock_enable_output_b => "BYPASS",
   init_file => "UNUSED",
   intended_device_family => "Cyclone V",
   lpm_type => "altsyncram",
   numwords_a => 2**widthad_a,
   numwords_b => 2**widthad_a,
   operation_mode => "DUAL_PORT",
   outdata_aclr_b => "NONE",
   outdata_reg_b => "UNREGISTERED",
   power_up_uninitialized => "FALSE",
   read_during_write_mode_mixed_ports => mixed_port_rdwr,
   widthad_a => widthad_a,
   widthad_b => widthad_a,
   width_a => width_a,
   width_b => width_a,
   width_byteena_a => 1
  )
  PORT MAP (
   wren_a => wren_a,
   clock0 => clock,
   address_a => address_a,
   address_b => address_b,
   data_a => data_a,
   q_b => q_b
  );
END SYN;
