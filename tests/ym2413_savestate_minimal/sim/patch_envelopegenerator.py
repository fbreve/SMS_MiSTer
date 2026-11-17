import os

path = r'rtl/VM2413/envelopegenerator.vhd'
with open(path, 'rb') as f:
    text = f.read()

# 1. Entity ports
target1 = b'        egout   : out   std_logic_vector( 12 downto 0 )     --  \x8f\xac\x90\x94\x95\x94 6bit\r\n    );\r\nend envelopegenerator;'

repl1 = (
    b'        egout   : out   std_logic_vector( 12 downto 0 )     --  \x8f\xac\x90\x94\x95\x94 6bit\r\n'
    b'    ;\r\n'
    b'        -- Approach C private, fixed-latency 32-bit access\r\n'
    b'        ss_hold : in std_logic := \'0\';\r\n'
    b'        ss_addr : in std_logic_vector(7 downto 0) := (others=>\'0\');\r\n'
    b'        ss_read : in std_logic := \'0\';\r\n'
    b'        ss_write : in std_logic := \'0\';\r\n'
    b'        ss_wdata : in std_logic_vector(31 downto 0) := (others=>\'0\');\r\n'
    b'        ss_rdata : out std_logic_vector(31 downto 0);\r\n'
    b'        ss_initialized : out std_logic\r\n'
    b'    );\r\n'
    b'end envelopegenerator;'
)

# 2. EnvelopeMemory component
target2 = (
    b'    component EnvelopeMemory\r\n'
    b'        port (\r\n'
    b'            clk     : in    std_logic;\r\n'
    b'            reset   : in    std_logic;\r\n\r\n'
    b'            waddr   : in    slot_type;\r\n'
    b'            wr      : in    std_logic;\r\n'
    b'            wdata   : in    egdata_type;\r\n'
    b'            raddr   : in    slot_type;\r\n'
    b'            rdata   : out   egdata_type\r\n'
    b'        );\r\n'
    b'    end component;'
)

repl2 = (
    b'    component EnvelopeMemory\r\n'
    b'        port (\r\n'
    b'            clk     : in    std_logic;\r\n'
    b'            reset   : in    std_logic;\r\n\r\n'
    b'            waddr   : in    slot_type;\r\n'
    b'            wr      : in    std_logic;\r\n'
    b'            wdata   : in    egdata_type;\r\n'
    b'            raddr   : in    slot_type;\r\n'
    b'            rdata   : buffer   egdata_type\r\n'
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

# 3. Add internal signals before begin
target_signals = b'    signal ardata   : std_logic_vector( 12 downto 0 );  --  \x8f\xac\x90\x94\x95\x94 6bit\r\nbegin'
repl_signals = (
    b'    signal ardata   : std_logic_vector( 12 downto 0 );  --  \x8f\xac\x90\x94\x95\x94 6bit\r\n'
    b'    signal ss_u_envelope_memory_data : std_logic_vector(31 downto 0);\r\n'
    b'    signal ss_u_envelope_memory_ready : std_logic;\r\n\r\n'
    b'begin'
)

# 4. EnvelopeMemory port map
target_map = (
    b'    u_envelope_memory: EnvelopeMemory\r\n'
    b'    port map (\r\n'
    b'        clk     =>  clk,\r\n'
    b'        reset   =>  reset,\r\n'
    b'        waddr   =>  slot,\r\n'
    b'        wr      =>  memwr,\r\n'
    b'        wdata   =>  memin,\r\n'
    b'        raddr   =>  rslot,\r\n'
    b'        rdata   =>  memout\r\n'
    b'    );'
)

repl_map = (
    b'    u_envelope_memory: EnvelopeMemory\r\n'
    b'    port map (\r\n'
    b'        clk     =>  clk,\r\n'
    b'        reset   =>  reset,\r\n'
    b'        waddr   =>  slot,\r\n'
    b'        wr      =>  memwr,\r\n'
    b'        wdata   =>  memin,\r\n'
    b'        raddr   =>  rslot,\r\n'
    b'        rdata   =>  memout,\r\n'
    b'        ss_hold =>  ss_hold,\r\n'
    b'        ss_addr =>  ss_addr,\r\n'
    b'        ss_read =>  ss_read,\r\n'
    b'        ss_write => ss_write,\r\n'
    b'        ss_wdata => ss_wdata,\r\n'
    b'        ss_rdata => ss_u_envelope_memory_data,\r\n'
    b'        ss_initialized => ss_u_envelope_memory_ready\r\n'
    b'    );'
)

assert target1 in text, "target1 missing"
text = text.replace(target1, repl1, 1)

assert target2 in text, "target2 missing"
text = text.replace(target2, repl2, 1)

assert target_signals in text, "target_signals missing"
text = text.replace(target_signals, repl_signals, 1)

assert target_map in text, "target_map missing"
text = text.replace(target_map, repl_map, 1)

# Check end of file for wiring outputs
p_end = text.rfind(b'end rtl;')
assert p_end != -1, "end rtl missing"
repl_end = (
    b'    ss_rdata <= ss_u_envelope_memory_data;\r\n'
    b'    ss_initialized <= ss_u_envelope_memory_ready;\r\n\r\n'
    b'end rtl;'
)

text = text[:p_end] + repl_end + text[p_end+len(b'end rtl;'):]

with open(path, 'wb') as f:
    f.write(text)

print('Updated envelopegenerator.vhd successfully!')
