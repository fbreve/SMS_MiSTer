import os

path = r'rtl/VM2413/voicememory.vhd'
with open(path, 'rb') as f:
    text = f.read()

target1 = b'    odata  : out VOICE_TYPE;\r\n    rodata : out VOICE_TYPE\r\n  );'
repl1 = (
    b'    odata  : buffer VOICE_TYPE;\r\n'
    b'    rodata : buffer VOICE_TYPE\r\n'
    b'  ;\r\n'
    b'        -- Approach C private, fixed-latency 32-bit access\r\n'
    b'        ss_hold : in std_logic := \'0\';\r\n'
    b'        ss_addr : in std_logic_vector(7 downto 0) := (others=>\'0\');\r\n'
    b'        ss_read : in std_logic := \'0\';\r\n'
    b'        ss_write : in std_logic := \'0\';\r\n'
    b'        ss_wdata : in std_logic_vector(31 downto 0) := (others=>\'0\');\r\n'
    b'        ss_rdata : out std_logic_vector(31 downto 0);\r\n'
    b'        ss_initialized : out std_logic\r\n'
    b'  );'
)

target2 = b'  signal rom_data : VOICE_TYPE;\r\n  signal rstate : integer range 0 to 2;\r\n\r\nbegin'
repl2 = (
    b'  signal rom_data : VOICE_TYPE;\r\n'
    b'  signal rstate : integer range 0 to 2;\r\n\r\n'
    b'    signal ss_local_data : std_logic_vector(31 downto 0) := (others=>\'0\');\r\n'
    b'    signal ss_mem_active : std_logic;\r\n'
    b'    signal ss_mem_index : integer range 0 to 37;\r\n'
    b'    signal ss_mem_ready : std_logic := \'0\';\r\n'
    b'    signal ss_voice_low : std_logic_vector(31 downto 0);\r\n'
    b'    signal ss_mem_vector : std_logic_vector(35 downto 0);\r\n\r\n'
    b'begin'
)

target3 = (
    b"if reset = '1' then\r\n\r\n"
    b"      init_id := 0;\r\n"
    b"      rstate <= 0;\r\n\r\n"
    b"    elsif rising_edge(clk) then\r\n\r\n"
    b"      if init_id /= VOICE_ID_TYPE'high+1 then\r\n\r\n"
    b"        case rstate is\r\n"
    b"        when 0 =>\r\n"
    b"          rom_addr <= init_id;\r\n"
    b"          rstate <= 1;\r\n"
    b"        when 1 =>\r\n"
    b"          rstate <= 2;\r\n"
    b"        when 2 =>\r\n"
    b"          voices(init_id) <= CONV_VOICE_VECTOR(rom_data);\r\n"
    b"          rstate <= 0;\r\n"
    b"          init_id := init_id + 1;\r\n"
    b"        end case;\r\n\r\n"
    b"      elsif wr = '1' then\r\n"
    b"        voices(rwaddr) <= CONV_VOICE_VECTOR(idata);\r\n"
    b"      end if;\r\n\r\n"
    b"      odata <= CONV_VOICE(voices(rwaddr));\r\n"
    b"      rodata <= CONV_VOICE(voices(roaddr));\r\n\r\n"
    b"    end if;\r\n\r\n"
    b"  end process;\r\n\r\n"
    b"end RTL;"
)

repl3 = (
    b"    if reset = '1' then\r\n"
    b"      ss_mem_ready <= '0';\r\n"
    b"      init_id := 0;\r\n"
    b"      rstate <= 0;\r\n"
    b"    elsif rising_edge(clk) then\r\n"
    b"      ss_mem_ready <= '0'; if init_id=38 then ss_mem_ready <= '1'; end if;\r\n"
    b"      if ss_hold='0' then\r\n"
    b"        if init_id /= VOICE_ID_TYPE'high+1 then\r\n"
    b"          case rstate is\r\n"
    b"          when 0 =>\r\n"
    b"            rom_addr <= init_id;\r\n"
    b"            rstate <= 1;\r\n"
    b"          when 1 =>\r\n"
    b"            rstate <= 2;\r\n"
    b"          when 2 =>\r\n"
    b"            voices(init_id) <= CONV_VOICE_VECTOR(rom_data);\r\n"
    b"            rstate <= 0;\r\n"
    b"            init_id := init_id + 1;\r\n"
    b"          end case;\r\n"
    b"        elsif wr = '1' then\r\n"
    b"          voices(rwaddr) <= CONV_VOICE_VECTOR(idata);\r\n"
    b"        end if;\r\n"
    b"      elsif ss_write='1' and ss_mem_active='1' then\r\n"
    b"        if ss_addr(0)='1' then ss_voice_low<=ss_wdata; else voices(ss_mem_index)<=ss_wdata(3 downto 0) & ss_voice_low; end if;\r\n"
    b"      end if;\r\n"
    b"      if ss_mem_active='1' then odata <= CONV_VOICE(voices(ss_mem_index)); else odata <= CONV_VOICE(voices(rwaddr)); end if;\r\n"
    b"      rodata <= CONV_VOICE(voices(roaddr));\r\n"
    b"    end if;\r\n"
    b"  end process;\r\n\r\n"
    b"  ss_mem_active <= '1' when ss_hold='1' and conv_integer(ss_addr)>=9 and conv_integer(ss_addr)<=12 else '0';\r\n"
    b"  ss_mem_index <= (conv_integer(ss_addr)-9)/2 when conv_integer(ss_addr)>=9 and conv_integer(ss_addr)<=12 else 0;\r\n"
    b"  ss_mem_vector <= CONV_VOICE_VECTOR(odata);\r\n"
    b"  ss_local_data <= ss_mem_vector(31 downto 0) when ss_mem_active='1' and ss_addr(0)='1' else (27 downto 0 => '0') & ss_mem_vector(35 downto 32) when ss_mem_active='1' else (others=>'0');\r\n"
    b"  ss_rdata <= ss_local_data;\r\n"
    b"  ss_initialized <= ss_mem_ready;\r\n"
    b"end RTL;"
)

assert target1 in text, "target1 missing"
text = text.replace(target1, repl1, 1)

assert target2 in text, "target2 missing"
text = text.replace(target2, repl2, 1)

assert target3 in text, "target3 missing"
text = text.replace(target3, repl3, 1)

with open(path, 'wb') as f:
    f.write(text)

print('Updated voicememory.vhd successfully!')
