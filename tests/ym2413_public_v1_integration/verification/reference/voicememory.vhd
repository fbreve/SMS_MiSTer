--
-- VoiceMemory.vhd
--
-- Copyright (c) 2006 Mitsutaka Okazaki (brezza@pokipoki.org)
-- All rights reserved.
--
-- Redistribution and use of this source code or any derivative works, are
-- permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
-- 3. Redistributions may not be sold, nor may they be used in a commercial
--    product or activity without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.VM2413.ALL;

use ieee.std_logic_arith.conv_std_logic_vector;
entity VoiceMemory is
  port (
    clk    : in std_logic;
    reset  : in std_logic;

    idata  : in VOICE_TYPE;
    wr     : in std_logic;
    rwaddr : in VOICE_ID_TYPE; -- read/write address
    roaddr : in VOICE_ID_TYPE; -- read only address
    odata  : buffer VOICE_TYPE;
    rodata : buffer VOICE_TYPE
  ;
        -- F01 private, fixed-latency 32-bit access; no emulated clock enables.
        ss_hold : in std_logic := '0';
        ss_addr : in std_logic_vector(7 downto 0) := (others=>'0');
        ss_read : in std_logic := '0';
        ss_write : in std_logic := '0';
        ss_wdata : in std_logic_vector(31 downto 0) := (others=>'0');
        ss_rdata : out std_logic_vector(31 downto 0);
        ss_initialized : out std_logic
);
end VoiceMemory;

architecture RTL of VoiceMemory is

  -- The following array is mapped into a Single-Clock Synchronous RAM with two-read
  -- addresses by Altera's QuartusII compiler.
  type VOICE_ARRAY_TYPE is array (0 to 37) of VOICE_VECTOR_TYPE;
  signal voices : VOICE_ARRAY_TYPE;

  component VoiceRom port (
    clk   : in std_logic;
    addr  : in VOICE_ID_TYPE;
    data  : buffer VOICE_TYPE
  );
  end component;

  signal rom_addr : VOICE_ID_TYPE;
  signal rom_data : VOICE_TYPE;
  signal rstate : integer range 0 to 2;

    signal ss_local_data : std_logic_vector(31 downto 0) := (others=>'0');
    signal ss_mem_active : std_logic;
    signal ss_mem_index : integer range 0 to 37;
    signal ss_mem_ready : std_logic := '0';
    signal ss_voice_low : std_logic_vector(31 downto 0);
    signal ss_mem_vector : std_logic_vector(35 downto 0);

begin

  ROM2413 : VoiceRom port map(clk, rom_addr, rom_data);

  process(clk, reset)

    variable init_id  : integer range 0 to VOICE_ID_TYPE'high+1;

  begin

    if reset = '1' then
ss_mem_ready <= '0';

      init_id := 0;
      rstate <= 0;

    elsif rising_edge(clk) then

      ss_mem_ready <= '0'; if init_id=38 then ss_mem_ready <= '1'; end if;
if ss_hold='0' then
if init_id /= VOICE_ID_TYPE'high+1 then

        case rstate is
        when 0 =>
          rom_addr <= init_id;
          rstate <= 1;
        when 1 =>
          rstate <= 2;
        when 2 =>
          voices(init_id) <= CONV_VOICE_VECTOR(rom_data);
          rstate <= 0;
          init_id := init_id + 1;
        when others => null; end case;

      elsif wr = '1' then
        voices(rwaddr) <= CONV_VOICE_VECTOR(idata);
      end if;


elsif ss_write='1' and ss_mem_active='1' then
if ss_addr(0)='1' then ss_voice_low<=ss_wdata; else voices(ss_mem_index)<=ss_wdata(3 downto 0) & ss_voice_low; end if;
end if;
if ss_mem_active='1' then odata <= CONV_VOICE(voices(ss_mem_index)); else odata <= CONV_VOICE(voices(rwaddr)); end if;
      rodata <= CONV_VOICE(voices(roaddr));

    end if;

  end process;
ss_mem_active <= '1' when ss_hold='1' and conv_integer(ss_addr)>=9 and conv_integer(ss_addr)<=12 else '0';
ss_mem_index <= (conv_integer(ss_addr)-9)/2 when conv_integer(ss_addr)>=9 and conv_integer(ss_addr)<=12 else 0;
ss_mem_vector <= CONV_VOICE_VECTOR(odata);
ss_local_data <= ss_mem_vector(31 downto 0) when ss_mem_active='1' and ss_addr(0)='1' else (27 downto 0 => '0') & ss_mem_vector(35 downto 32) when ss_mem_active='1' else (others=>'0');


ss_rdata <= ss_local_data;
ss_initialized <= ss_mem_ready;

verify_word_9 <= voices(0)(31 downto 0);
verify_word_10 <= (27 downto 0=>'0') & voices(0)(35 downto 32);
verify_word_11 <= voices(1)(31 downto 0);
verify_word_12 <= (27 downto 0=>'0') & voices(1)(35 downto 32);
verify_factory_voices(35 downto 0) <= voices(2);
verify_factory_voices(71 downto 36) <= voices(3);
verify_factory_voices(107 downto 72) <= voices(4);
verify_factory_voices(143 downto 108) <= voices(5);
verify_factory_voices(179 downto 144) <= voices(6);
verify_factory_voices(215 downto 180) <= voices(7);
verify_factory_voices(251 downto 216) <= voices(8);
verify_factory_voices(287 downto 252) <= voices(9);
verify_factory_voices(323 downto 288) <= voices(10);
verify_factory_voices(359 downto 324) <= voices(11);
verify_factory_voices(395 downto 360) <= voices(12);
verify_factory_voices(431 downto 396) <= voices(13);
verify_factory_voices(467 downto 432) <= voices(14);
verify_factory_voices(503 downto 468) <= voices(15);
verify_factory_voices(539 downto 504) <= voices(16);
verify_factory_voices(575 downto 540) <= voices(17);
verify_factory_voices(611 downto 576) <= voices(18);
verify_factory_voices(647 downto 612) <= voices(19);
verify_factory_voices(683 downto 648) <= voices(20);
verify_factory_voices(719 downto 684) <= voices(21);
verify_factory_voices(755 downto 720) <= voices(22);
verify_factory_voices(791 downto 756) <= voices(23);
verify_factory_voices(827 downto 792) <= voices(24);
verify_factory_voices(863 downto 828) <= voices(25);
verify_factory_voices(899 downto 864) <= voices(26);
verify_factory_voices(935 downto 900) <= voices(27);
verify_factory_voices(971 downto 936) <= voices(28);
verify_factory_voices(1007 downto 972) <= voices(29);
verify_factory_voices(1043 downto 1008) <= voices(30);
verify_factory_voices(1079 downto 1044) <= voices(31);
verify_factory_voices(1115 downto 1080) <= voices(32);
verify_factory_voices(1151 downto 1116) <= voices(33);
verify_factory_voices(1187 downto 1152) <= voices(34);
verify_factory_voices(1223 downto 1188) <= voices(35);
verify_factory_voices(1259 downto 1224) <= voices(36);
verify_factory_voices(1295 downto 1260) <= voices(37);
end rtl;
