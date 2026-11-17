import os

path = r'rtl/VM2413/registermemory.vhd'
with open(path, 'rb') as f:
    text = f.read()

target1 = b'        odata   : out   std_logic_vector( 23 downto 0 )\r\n    );\r\nend RegisterMemory;'
repl1 = (
    b'        odata   : buffer   std_logic_vector( 23 downto 0 )\r\n'
    b'    ;\r\n'
    b'        -- Approach C private, fixed-latency 32-bit access\r\n'
    b'        ss_hold : in std_logic := \'0\';\r\n'
    b'        ss_addr : in std_logic_vector(7 downto 0) := (others=>\'0\');\r\n'
    b'        ss_read : in std_logic := \'0\';\r\n'
    b'        ss_write : in std_logic := \'0\';\r\n'
    b'        ss_wdata : in std_logic_vector(31 downto 0) := (others=>\'0\');\r\n'
    b'        ss_rdata : out std_logic_vector(31 downto 0);\r\n'
    b'        ss_initialized : out std_logic\r\n'
    b');\r\n'
    b'end RegisterMemory;'
)

target2 = b'    attribute ramstyle of regs_array : signal is "logic";\r\n\r\nbegin'
repl2 = (
    b'    attribute ramstyle of regs_array : signal is "logic";\r\n\r\n'
    b'    signal ss_local_data : std_logic_vector(31 downto 0) := (others=>\'0\');\r\n'
    b'    signal ss_mem_active : std_logic;\r\n'
    b'    signal ss_mem_index : integer range 0 to 8;\r\n'
    b'    signal ss_mem_ready : std_logic := \'0\';\r\n'
    b'    signal ss_mem_vector : std_logic_vector(23 downto 0);\r\n\r\n'
    b'begin'
)

target3 = (
    b'        if( reset = \'1\' )then\r\n'
    b'            init_state := 0;\r\n'
    b'        elsif rising_edge(clk) then\r\n'
    b'            if( init_state /= 9 )then\r\n'
    b'                --  \x8bN\x93\xae\x82\xb5\x82\xc4\x82\xb7\x82\xae\x82\xc9 RAM \x82\xcc\x93\xe0\x97e\x82\xf0\x8f\x89\x8a\xfa\x89\xbb\x82\xb7\x82\xe9\r\n'
    b'                regs_array( init_state ) <= (others => \'0\');\r\n'
    b'                init_state := init_state + 1;\r\n'
    b'            elsif( wr = \'1\' )then\r\n'
    b'                --  \x8f\x91\x82\xab\x8d\x9e\x82\xdd\x83T\x83C\x83N\x83\x8b\r\n'
    b'                regs_array( conv_integer(addr) ) <= idata;\r\n'
    b'            end if;\r\n'
    b'            --  \x93\xc7\x82\xdd\x8fo\x82\xb5\x82\xcd\x8f\xed\x8e\x9e\r\n'
    b'            odata <= regs_array( conv_integer(addr) );\r\n'
    b'        end if;\r\n'
    b'    end process;\r\n'
)

repl3 = (
    b'        if( reset = \'1\' )then\r\n'
    b'            ss_mem_ready <= \'0\';\r\n'
    b'            init_state := 0;\r\n'
    b'        elsif rising_edge(clk) then\r\n'
    b'            ss_mem_ready <= \'0\'; if init_state=9 then ss_mem_ready <= \'1\'; end if;\r\n'
    b'            if ss_hold=\'0\' then\r\n'
    b'                if( init_state /= 9 )then\r\n'
    b'                    regs_array( init_state ) <= (others => \'0\');\r\n'
    b'                    init_state := init_state + 1;\r\n'
    b'                elsif( wr = \'1\' )then\r\n'
    b'                    regs_array( conv_integer(addr) ) <= idata;\r\n'
    b'                end if;\r\n'
    b'            elsif ss_write=\'1\' and ss_mem_active=\'1\' then\r\n'
    b'                regs_array(ss_mem_index) <= ss_wdata(21 downto 14) & "00" & ss_wdata(13 downto 0);\r\n'
    b'            end if;\r\n'
    b'            if ss_mem_active=\'1\' then odata <= regs_array(ss_mem_index); else odata <= regs_array( conv_integer(addr) ); end if;\r\n'
    b'        end if;\r\n'
    b'    end process;\r\n\r\n'
    b'    ss_mem_active <= \'1\' when ss_hold=\'1\' and conv_integer(ss_addr)>=0 and conv_integer(ss_addr)<=8 else \'0\';\r\n'
    b'    ss_mem_index <= conv_integer(ss_addr) when conv_integer(ss_addr)>=0 and conv_integer(ss_addr)<=8 else 0;\r\n'
    b'    ss_mem_vector <= odata;\r\n'
    b'    ss_local_data <= (9 downto 0 => \'0\') & ss_mem_vector(23 downto 16) & ss_mem_vector(13 downto 0) when ss_mem_active=\'1\' else (others=>\'0\');\r\n'
    b'    ss_rdata <= ss_local_data;\r\n'
    b'    ss_initialized <= ss_mem_ready;\r\n'
)

assert target1 in text, "target1 missing"
text = text.replace(target1, repl1, 1)

assert target2 in text, "target2 missing"
text = text.replace(target2, repl2, 1)

assert target3 in text, "target3 missing"
text = text.replace(target3, repl3, 1)

with open(path, 'wb') as f:
    f.write(text)

print('Updated registermemory.vhd successfully!')

