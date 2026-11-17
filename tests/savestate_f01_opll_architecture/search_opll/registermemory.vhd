--
-- RegisterMemory.vhd
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

--
--  modified by t.hara
--




































library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity RegisterMemory is
    port (
        clk     : in    std_logic;
        reset   : in    std_logic;
        addr    : in    std_logic_vector(  3 downto 0 );
        wr      : in    std_logic;
        idata   : in    std_logic_vector( 23 downto 0 );
        odata   : out   std_logic_vector( 23 downto 0 )
    );
end RegisterMemory;

use work.audit_pkg.all;
architecture rtl of registermemory is
    
    type regs_array_type is array (0 to 8) of std_logic_vector( 23 downto 0 );
    signal regs_array : regs_array_type;
    attribute ramstyle : string;
    attribute ramstyle of regs_array : signal is "logic";

begin
    process( reset, clk )
        variable init_state : integer range 0 to 9;
    
variable audit_s_regs_array : regs_array'subtype;
variable audit_s_odata : odata'subtype;
variable audit_v_init_state : integer range 0 to 9;
begin
if audit_action=1 then
 if rising_edge(clk) then
audit_s_regs_array:=regs_array;
audit_s_odata:=odata;
audit_v_init_state:=init_state;
end if;
elsif audit_action=2 then
if rising_edge(clk) and audit_omit/=7 then
regs_array<=audit_s_regs_array;
if audit_omit/=9 then odata<=audit_s_odata; end if;
init_state:=audit_v_init_state;
end if;
else

        if( reset = '1' )then
            init_state := 0;
        elsif rising_edge(clk) then
            if( init_state /= 9 )then
                
                regs_array( init_state ) <= (others => '0');
                init_state := init_state + 1;
            elsif( wr = '1' )then
                
                regs_array( conv_integer(addr) ) <= idata;
            end if;
            
            odata <= regs_array( conv_integer(addr) );
        end if;
    
end if;
end process;
end rtl;
