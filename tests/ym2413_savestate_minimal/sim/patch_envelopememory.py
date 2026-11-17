import os

path = r'rtl/VM2413/envelopememory.vhd'
with open(path, 'rb') as f:
    text = f.read()

target1 = b'  rdata   : out EGDATA_TYPE\r\n  );'
repl1 = (
    b'  rdata   : buffer EGDATA_TYPE\r\n'
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

target2 = b'  type EGDATA_ARRAY is array (0 to 18-1) of EGDATA_VECTOR_TYPE;\r\n  signal egdata_set : EGDATA_ARRAY;\r\n\r\nbegin'
repl2 = (
    b'  type EGDATA_ARRAY is array (0 to 18-1) of EGDATA_VECTOR_TYPE;\r\n'
    b'  signal egdata_set : EGDATA_ARRAY;\r\n\r\n'
    b'    signal ss_local_data : std_logic_vector(31 downto 0) := (others=>\'0\');\r\n'
    b'    signal ss_mem_active : std_logic;\r\n'
    b'    signal ss_mem_index : integer range 0 to 17;\r\n'
    b'    signal ss_mem_ready : std_logic := \'0\';\r\n'
    b'    signal ss_mem_vector : std_logic_vector(24 downto 0);\r\n\r\n'
    b'begin'
)

target3 = (
    b"if reset = '1' then\r\n\r\n"
    b"     init_slot := 0;\r\n\r\n"
    b"   elsif rising_edge(clk) then\r\n\r\n"
    b"     if init_slot /= 18 then\r\n"
    b"       egdata_set(init_slot) <= (others=>'1');\r\n"
    b"       init_slot := init_slot + 1;\r\n"
    b"     elsif wr = '1' then\r\n"
    b"       egdata_set(conv_integer(waddr)) <= CONV_EGDATA_VECTOR(wdata);\r\n"
    b"     end if;\r\n"
    b"     rdata <= CONV_EGDATA(egdata_set(conv_integer(raddr)));\r\n\r\n"
    b"   end if;\r\n\r\n"
    b"end process;\r\n\r\n"
    b"end RTL;"
)

repl3 = (
    b"    if reset = '1' then\r\n"
    b"      ss_mem_ready <= '0';\r\n"
    b"      init_slot := 0;\r\n"
    b"    elsif rising_edge(clk) then\r\n"
    b"      ss_mem_ready <= '0'; if init_slot=18 then ss_mem_ready <= '1'; end if;\r\n"
    b"      if ss_hold='0' then\r\n"
    b"        if init_slot /= 18 then\r\n"
    b"          egdata_set(init_slot) <= (others=>'1');\r\n"
    b"          init_slot := init_slot + 1;\r\n"
    b"        elsif wr = '1' then\r\n"
    b"          egdata_set(conv_integer(waddr)) <= CONV_EGDATA_VECTOR(wdata);\r\n"
    b"        end if;\r\n"
    b"      elsif ss_write='1' and ss_mem_active='1' then\r\n"
    b"        egdata_set(ss_mem_index) <= ss_wdata(24 downto 0);\r\n"
    b"      end if;\r\n"
    b"      if ss_mem_active='1' then rdata <= CONV_EGDATA(egdata_set(ss_mem_index)); else rdata <= CONV_EGDATA(egdata_set(conv_integer(raddr))); end if;\r\n"
    b"    end if;\r\n"
    b"  end process;\r\n\r\n"
    b"  ss_mem_active <= '1' when ss_hold='1' and conv_integer(ss_addr)>=13 and conv_integer(ss_addr)<=30 else '0';\r\n"
    b"  ss_mem_index <= conv_integer(ss_addr)-13 when conv_integer(ss_addr)>=13 and conv_integer(ss_addr)<=30 else 0;\r\n"
    b"  ss_mem_vector <= CONV_EGDATA_VECTOR(rdata);\r\n"
    b"  ss_local_data <= (6 downto 0 => '0') & ss_mem_vector when ss_mem_active='1' else (others=>'0');\r\n"
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

print('Updated envelopememory.vhd successfully!')

