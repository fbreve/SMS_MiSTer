import os

path = r'rtl/VM2413/opll.vhd'
with open(path, 'rb') as f:
    text = f.read()

# 1. Entity ports
p_port = text.find(b'mixout      : out std_logic_vector(13 downto 0 )')
p_end_port = text.find(b');', p_port)

target_port = text[p_port:p_end_port+2]
repl_port = (
    b'mixout      : out std_logic_vector(13 downto 0 )\r\n'
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

# 2. Components controller & envelopegenerator
p_comp_ct = text.find(b'component controller port (')
p_end_comp_ct = text.find(b'end component;', p_comp_ct)
target_comp_ct = text[p_comp_ct:p_end_comp_ct+len(b'end component;')]
repl_comp_ct = (
    b'component controller port (\r\n'
    b'        clk     : in    std_logic;\r\n'
    b'        reset   : in    std_logic;\r\n'
    b'        clkena  : in    std_logic;\r\n\r\n'
    b'        slot    : in    slot_type;\r\n'
    b'        stage   : in    stage_type;\r\n\r\n'
    b'        wr      : in    std_logic;\r\n'
    b'        addr    : in    std_logic_vector( 7 downto 0 );\r\n'
    b'        data    : in    std_logic_vector( 7 downto 0 );\r\n\r\n'
    b'        am      : out   am_type;\r\n'
    b'        pm      : out   pm_type;\r\n'
    b'        wf      : out   wf_type;\r\n'
    b'        ml      : out   ml_type;\r\n'
    b'        tl      : out   db_type;\r\n'
    b'        fb      : out   fb_type;\r\n'
    b'        ar      : out   ar_type;\r\n'
    b'        dr      : out   dr_type;\r\n'
    b'        sl      : out   sl_type;\r\n'
    b'        rr      : out   rr_type;\r\n'
    b'        blk     : out   blk_type;\r\n'
    b'        fnum    : out   fnum_type;\r\n'
    b'        rks     : out   rks_type;\r\n'
    b'        key     : out   std_logic;\r\n'
    b'        rhythm  : out   std_logic\r\n'
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

p_comp_eg = text.find(b'component envelopegenerator')
p_end_comp_eg = text.find(b'end component;', p_comp_eg)
target_comp_eg = text[p_comp_eg:p_end_comp_eg+len(b'end component;')]
repl_comp_eg = (
    b'component envelopegenerator\r\n'
    b'    port (\r\n'
    b'        clk     : in    std_logic;\r\n'
    b'        reset   : in    std_logic;\r\n'
    b'        clkena  : in    std_logic;\r\n\r\n'
    b'        slot    : in    slot_type;\r\n'
    b'        stage   : in    stage_type;\r\n'
    b'        rhythm  : in    std_logic;\r\n\r\n'
    b'        am      : in    am_type;\r\n'
    b'        tl      : in    db_type;\r\n'
    b'        ar      : in    ar_type;\r\n'
    b'        dr      : in    dr_type;\r\n'
    b'        sl      : in    sl_type;\r\n'
    b'        rr      : in    rr_type;\r\n'
    b'        rks     : in    rks_type;\r\n'
    b'        key     : in    std_logic;\r\n\r\n'
    b'        egout   : out   std_logic_vector( 12 downto 0 )\r\n'
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
p_arch_begin = text.find(b'begin\r\n\r\n    xout    <= xin;')
assert p_arch_begin != -1
repl_arch_sigs = (
    b'    signal ss_local_data : std_logic_vector(31 downto 0) := (others=>\'0\');\r\n'
    b'    signal ss_ct_data : std_logic_vector(31 downto 0);\r\n'
    b'    signal ss_ct_ready : std_logic;\r\n'
    b'    signal ss_eg_data : std_logic_vector(31 downto 0);\r\n'
    b'    signal ss_eg_ready : std_logic;\r\n\r\n'
    b'begin\r\n\r\n    xout    <= xin;'
)

# 4. Bus process (opllptr, oplldat, opllwr)
p_proc = text.find(b'process( xin, reset )\r\n    begin')
p_end_proc = text.find(b'end process;', p_proc)
target_proc = text[p_proc:p_end_proc+len(b'end process;')]
repl_proc = (
    b'process( xin, reset )\r\n'
    b'    begin\r\n'
    b'        if( reset =\'1\' )then\r\n'
    b'            opllwr  <= \'0\';\r\n'
    b'            opllptr <= (others =>\'0\');\r\n'
    b'            ss_local_data <= (others => \'0\');\r\n'
    b'        elsif rising_edge(xin) then\r\n'
    b'            if ss_hold = \'1\' then\r\n'
    b'                if ss_read = \'1\' and conv_integer(ss_addr) = 31 then\r\n'
    b'                    ss_local_data <= (31 downto 24 => \'0\') & opllwr & opllptr & (14 downto 0 => \'0\');\r\n'
    b'                else\r\n'
    b'                    ss_local_data <= (others => \'0\');\r\n'
    b'                end if;\r\n'
    b'                if ss_write = \'1\' and conv_integer(ss_addr) = 31 then\r\n'
    b'                    opllptr <= ss_wdata(22 downto 15);\r\n'
    b'                    opllwr <= ss_wdata(23);\r\n'
    b'                end if;\r\n'
    b'            elsif( xena = \'1\' )then\r\n'
    b'                ss_local_data <= (others => \'0\');\r\n'
    b'                if(    cs_n = \'0\' and we_n = \'0\' and a = \'0\' )then\r\n'
    b'                    opllptr <= d;\r\n'
    b'                    opllwr  <= \'0\';\r\n'
    b'                elsif( cs_n = \'0\' and we_n = \'0\' and a = \'1\' )then\r\n'
    b'                    oplldat <= d;\r\n'
    b'                    opllwr  <= \'1\';\r\n'
    b'                end if;\r\n'
    b'            end if;\r\n'
    b'        end if;\r\n'
    b'    end process;'
)

# 5. ct and eg port maps
p_map_ct = text.find(b'ct: controller port map (')
p_end_map_ct = text.find(b');', p_map_ct)
target_map_ct = text[p_map_ct:p_end_map_ct+2]
repl_map_ct = (
    b'ct: controller port map (\r\n'
    b'        xin,reset,xena, slot, stage, opllwr,opllptr,oplldat,\r\n'
    b'        am,pm,wf,ml,tl,fb,ar,dr,sl,rr,blk,fnum,rks,key,rhythm,\r\n'
    b'        ss_hold, ss_addr, ss_read, ss_write, ss_wdata, ss_ct_data, ss_ct_ready\r\n'
    b'    );'
)

p_map_eg = text.find(b'eg: envelopegenerator port map (')
p_end_map_eg = text.find(b');', p_map_eg)
target_map_eg = text[p_map_eg:p_end_map_eg+2]
repl_map_eg = (
    b'eg: envelopegenerator port map (\r\n'
    b'        xin,reset,xena,\r\n'
    b'        slot2, stage2, rhythm,\r\n'
    b'        am, tl, ar, dr, sl, rr, rks, key,\r\n'
    b'        egout,\r\n'
    b'        ss_hold, ss_addr, ss_read, ss_write, ss_wdata, ss_eg_data, ss_eg_ready\r\n'
    b'    );'
)

# 6. End of rtl outputs
p_end_rtl = text.rfind(b'end rtl;')
repl_end_rtl = (
    b'    ss_rdata <= ss_local_data or ss_ct_data or ss_eg_data;\r\n'
    b'    ss_initialized <= \'1\' and ss_ct_ready and ss_eg_ready;\r\n\r\n'
    b'end rtl;'
)

text = text.replace(target_port, repl_port, 1)
text = text.replace(target_comp_ct, repl_comp_ct, 1)
text = text.replace(target_comp_eg, repl_comp_eg, 1)
text = text.replace(b'begin\r\n\r\n    xout    <= xin;', repl_arch_sigs, 1)
text = text.replace(target_proc, repl_proc, 1)
text = text.replace(target_map_ct, repl_map_ct, 1)
text = text.replace(target_map_eg, repl_map_eg, 1)
text = text[:text.rfind(b'end rtl;')] + repl_end_rtl

with open(path, 'wb') as f:
    f.write(text)

print('Updated opll.vhd successfully!')

