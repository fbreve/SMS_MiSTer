import os

path = r'rtl/system.vhd'
with open(path, 'rb') as f:
    text = f.read()

# 1. System entity ports
p_port = text.find(b'ss_freeze     : in  STD_LOGIC := \'0\'')
assert p_port != -1
repl_ports = (
    b'ss_freeze     : in  STD_LOGIC := \'0\';\r\n'
    b'        fm_state_addr : in std_logic_vector(7 downto 0) := (others=>\'0\');\r\n'
    b'        fm_state_read : in std_logic := \'0\';\r\n'
    b'        fm_state_write : in std_logic := \'0\';\r\n'
    b'        fm_state_wdata : in std_logic_vector(31 downto 0) := (others=>\'0\');\r\n'
    b'        fm_state_rdata : out std_logic_vector(31 downto 0);\r\n'
    b'        fm_initialized : out std_logic;\r\n'
    b'        fm_legacy_reset : in std_logic := \'0\''
)

# 2. Architecture signals
p_sig = text.find(b'signal fm_WR_n:\t   \tstd_logic;')
assert p_sig != -1
repl_sigs = (
    b'signal fm_WR_n:\t   \tstd_logic;\r\n'
    b'    signal fm_local_rdata, fm_wrapper_rdata : std_logic_vector(31 downto 0);'
)

# 3. fm: work.opll instance
p_fm = text.find(b'fm: work.opll\r\n\tport map\r\n\t(\r\n')
p_end_fm = text.find(b');', p_fm)
target_fm = text[p_fm:p_end_fm+2]

repl_fm = (
    b'fm: work.opll\r\n'
    b'\tport map\r\n'
    b'\t(\r\n'
    b'\t\txin\t\t=> clk_sys,\r\n'
    b'\t\txena\t\t=> ce_cpu,\r\n'
    b'\t\td        => fm_d,\r\n'
    b'\t\ta        => fm_a,\r\n'
    b'\t\tcs_n     => \'0\',\r\n'
    b'\t\twe_n\t\t=> \'0\',\r\n'
    b'\t\tic_n\t\t=> RESET_n and not fm_legacy_reset,\r\n'
    b'\t\tmixout   => FM_out,\r\n'
    b'        ss_hold => ss_freeze,\r\n'
    b'        ss_addr => fm_state_addr,\r\n'
    b'        ss_read => fm_state_read,\r\n'
    b'        ss_write => fm_state_write,\r\n'
    b'        ss_wdata => fm_state_wdata,\r\n'
    b'        ss_rdata => fm_local_rdata,\r\n'
    b'        ss_initialized => fm_initialized\r\n'
    b'\t);'
)

# 4. fm_d / fm_a process and wrapper rdata
p_proc = text.find(b'process (clk_sys)\r\n\tbegin\r\n\t\tif rising_edge(clk_sys) then\r\n\t\t\tif RESET_n=\'0\' then')
p_end_proc = text.find(b'end process;', p_proc)
target_proc = text[p_proc:p_end_proc+len(b'end process;')]

repl_proc = (
    b'process (clk_sys)\r\n'
    b'\tbegin\r\n'
    b'\t\tif rising_edge(clk_sys) then\r\n'
    b'\t\t\tif RESET_n=\'0\' or fm_legacy_reset=\'1\' then\r\n'
    b'\t\t\t\tfm_d <= (others => \'0\');\r\n'
    b'\t\t\t\tfm_a <= \'0\';\r\n'
    b'            elsif ss_freeze=\'1\' and fm_state_write=\'1\' and conv_integer(fm_state_addr)=31 then\r\n'
    b'                fm_d <= fm_state_wdata(13 downto 6);\r\n'
    b'                fm_a <= fm_state_wdata(14);\r\n'
    b'\t\t\telsif ss_freeze = \'0\' and fm_WR_n=\'0\' then\r\n'
    b'\t\t\t\tfm_d <= D_in;\r\n'
    b'\t\t\t\tfm_a <= A(0);\r\n'
    b'\t\t\tend if;\r\n'
    b'\t\tend if;\r\n'
    b'\tend process;\r\n\r\n'
    b'    process (clk_sys)\r\n'
    b'    begin\r\n'
    b'        if rising_edge(clk_sys) then\r\n'
    b'            fm_wrapper_rdata <= (others => \'0\');\r\n'
    b'            if ss_freeze = \'1\' and fm_state_read = \'1\' and conv_integer(fm_state_addr) = 31 then\r\n'
    b'                fm_wrapper_rdata <= (31 downto 15 => \'0\') & fm_a & fm_d & (5 downto 0 => \'0\');\r\n'
    b'            end if;\r\n'
    b'        end if;\r\n'
    b'    end process;\r\n'
    b'    fm_state_rdata <= fm_local_rdata or fm_wrapper_rdata;'
)

text = text.replace(b'ss_freeze     : in  STD_LOGIC := \'0\'', repl_ports, 1)
text = text.replace(b'signal fm_WR_n:\t   \tstd_logic;', repl_sigs, 1)
text = text.replace(target_fm, repl_fm, 1)
text = text.replace(target_proc, repl_proc, 1)

with open(path, 'wb') as f:
    f.write(text)

print('Updated system.vhd successfully!')

