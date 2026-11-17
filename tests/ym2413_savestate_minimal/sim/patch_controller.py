import os

path = r'rtl/VM2413/controller.vhd'
with open(path, 'rb') as f:
    text = f.read()

# 1. Entity port list
p_port = text.find(b'rhythm  : out   std_logic')
assert p_port != -1
p_end_port = text.find(b');', p_port)

target_port = text[p_port:p_end_port+2]
repl_port = (
    b'rhythm  : out   std_logic\r\n'
    b'    ;\r\n'
    b'        -- Approach C private, fixed-latency 32-bit access\r\n'
    b'        ss_hold : in std_logic := \'0\';\r\n'
    b'        ss_addr : in std_logic_vector(7 downto 0) := (others=>\'0\');\r\n'
    b'        ss_read : in std_logic := \'0\';\r\n'
    b'        ss_write : in std_logic := \'0\';\r\n'
    b'        ss_wdata : in std_logic_vector(31 downto 0) := (others=>\'0\');\r\n'
    b'        ss_rdata : out std_logic_vector(31 downto 0);\r\n'
    b'        ss_initialized : out std_logic\r\n'
    b'    );'
)

# 2. RegisterMemory and VoiceMemory components
p_rm = text.find(b'component registermemory')
p_end_rm = text.find(b'end component;', p_rm)
target_rm = text[p_rm:p_end_rm+len(b'end component;')]
repl_rm = (
    b'component registermemory\r\n'
    b'        port (\r\n'
    b'            clk     : in    std_logic;\r\n'
    b'            reset   : in    std_logic;\r\n'
    b'            addr    : in    std_logic_vector(  3 downto 0 );\r\n'
    b'            wr      : in    std_logic;\r\n'
    b'            idata   : in    std_logic_vector( 23 downto 0 );\r\n'
    b'            odata   : buffer   std_logic_vector( 23 downto 0 )\r\n'
    b'        ;\r\n'
    b'            ss_hold : in std_logic := \'0\';\r\n'
    b'            ss_addr : in std_logic_vector(7 downto 0) := (others=>\'0\');\r\n'
    b'            ss_read : in std_logic := \'0\';\r\n'
    b'            ss_write : in std_logic := \'0\';\r\n'
    b'            ss_wdata : in std_logic_vector(31 downto 0) := (others=>\'0\');\r\n'
    b'            ss_rdata : out std_logic_vector(31 downto 0);\r\n'
    b'            ss_initialized : out std_logic\r\n'
    b'        );\r\n'
    b'    end component;'
)

p_vm = text.find(b'component voicememory')
p_end_vm = text.find(b'end component;', p_vm)
target_vm = text[p_vm:p_end_vm+len(b'end component;')]
repl_vm = (
    b'component voicememory port (\r\n'
    b'        clk     : in std_logic;\r\n'
    b'        reset   : in std_logic;\r\n'
    b'        idata   : in voice_type;\r\n'
    b'        wr       : in std_logic;\r\n'
    b'        rwaddr : in voice_id_type;\r\n'
    b'        roaddr : in voice_id_type;\r\n'
    b'        odata   : buffer voice_type;\r\n'
    b'        rodata : buffer voice_type\r\n'
    b'    ;\r\n'
    b'        ss_hold : in std_logic := \'0\';\r\n'
    b'        ss_addr : in std_logic_vector(7 downto 0) := (others=>\'0\');\r\n'
    b'        ss_read : in std_logic := \'0\';\r\n'
    b'        ss_write : in std_logic := \'0\';\r\n'
    b'        ss_wdata : in std_logic_vector(31 downto 0) := (others=>\'0\');\r\n'
    b'        ss_rdata : out std_logic_vector(31 downto 0);\r\n'
    b'        ss_initialized : out std_logic\r\n'
    b'    );\r\n'
    b'    end component;'
)

# 3. Add internal ss signals before begin
p_arch_begin = text.find(b'begin   -- rtl')
assert p_arch_begin != -1
repl_arch_sigs = (
    b'    signal ss_local_data : std_logic_vector(31 downto 0) := (others=>\'0\');\r\n'
    b'    signal ss_u_register_memory_data : std_logic_vector(31 downto 0);\r\n'
    b'    signal ss_u_register_memory_ready : std_logic;\r\n'
    b'    signal ss_vmem_data : std_logic_vector(31 downto 0);\r\n'
    b'    signal ss_vmem_ready : std_logic;\r\n\r\n'
    b'begin   -- rtl'
)

# 4. Port maps for u_register_memory and vmem
p_map_rm = text.find(b'u_register_memory : RegisterMemory')
p_end_map_rm = text.find(b');', p_map_rm)
target_map_rm = text[p_map_rm:p_end_map_rm+2]
repl_map_rm = (
    b'u_register_memory : RegisterMemory\r\n'
    b'    port map (\r\n'
    b'        clk     => clk,\r\n'
    b'        reset   => reset,\r\n'
    b'        addr    => regs_addr,\r\n'
    b'        wr      => regs_wr,\r\n'
    b'        idata   => regs_wdata,\r\n'
    b'        odata   => regs_rdata,\r\n'
    b'        ss_hold => ss_hold,\r\n'
    b'        ss_addr => ss_addr,\r\n'
    b'        ss_read => ss_read,\r\n'
    b'        ss_write => ss_write,\r\n'
    b'        ss_wdata => ss_wdata,\r\n'
    b'        ss_rdata => ss_u_register_memory_data,\r\n'
    b'        ss_initialized => ss_u_register_memory_ready\r\n'
    b'    );'
)

p_map_vm = text.find(b'vmem : voicememory port map')
p_end_map_vm = text.find(b');', p_map_vm)
target_map_vm = text[p_map_vm:p_end_map_vm+2]
repl_map_vm = (
    b'vmem : voicememory port map (\r\n'
    b'        clk, reset, user_voice_wdata, user_voice_wr, user_voice_addr, slot_voice_addr,\r\n'
    b'        user_voice_rdata, slot_voice_data,\r\n'
    b'        ss_hold, ss_addr, ss_read, ss_write, ss_wdata, ss_vmem_data, ss_vmem_ready\r\n'
    b'    );'
)

# 5. Main process modifications:
# Before main process begin, add snapshot handling for rflag at addr 31
p_main_proc = text.find(b'elsif rising_edge(clk) then if clkena=\'1\' then')
p_end_main_proc = text.find(b'end process;', p_main_proc)
target_main_proc = text[p_main_proc:p_end_main_proc+len(b'end process;')]

repl_main_proc = (
    b'elsif rising_edge(clk) then\r\n'
    b'            if ss_hold = \'1\' then\r\n'
    b'                if ss_read = \'1\' and conv_integer(ss_addr) = 31 then\r\n'
    b'                    ss_local_data <= (31 downto 6 => \'0\') & rflag(5 downto 0);\r\n'
    b'                else\r\n'
    b'                    ss_local_data <= (others => \'0\');\r\n'
    b'                end if;\r\n'
    b'                if ss_write = \'1\' and conv_integer(ss_addr) = 31 then\r\n'
    b'                    rflag(5 downto 0) <= ss_wdata(5 downto 0);\r\n'
    b'                end if;\r\n'
    b'            elsif clkena=\'1\' then\r\n'
    b'                ss_local_data <= (others => \'0\');\r\n'
    + text[p_main_proc + len(b'elsif rising_edge(clk) then if clkena=\'1\' then'):p_end_main_proc]
    + b'end process;'
)

# 6. End of architecture outputs
p_end_rtl = text.rfind(b'end rtl;')
repl_end_rtl = (
    b'    ss_rdata <= ss_local_data or ss_u_register_memory_data or ss_vmem_data;\r\n'
    b'    ss_initialized <= \'1\' and ss_u_register_memory_ready and ss_vmem_ready;\r\n\r\n'
    b'end rtl;'
)

text = text.replace(target_port, repl_port, 1)
text = text.replace(target_rm, repl_rm, 1)
text = text.replace(target_vm, repl_vm, 1)
text = text.replace(b'begin   -- rtl', repl_arch_sigs, 1)
text = text.replace(target_map_rm, repl_map_rm, 1)
text = text.replace(target_map_vm, repl_map_vm, 1)
text = text.replace(target_main_proc, repl_main_proc, 1)
text = text[:text.rfind(b'end rtl;')] + repl_end_rtl

with open(path, 'wb') as f:
    f.write(text)

print('Updated controller.vhd successfully!')

