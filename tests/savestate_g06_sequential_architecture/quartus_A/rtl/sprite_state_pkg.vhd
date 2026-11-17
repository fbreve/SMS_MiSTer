library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package sprite_state_pkg is
 function ss_bool(value:boolean) return std_logic_vector;
 function ss_extract(value:std_logic_vector; base:integer; address:std_logic_vector) return std_logic_vector;
 function ss_merge(value:std_logic_vector; base:integer; address:std_logic_vector; data:std_logic_vector(31 downto 0)) return std_logic_vector;
 function ss_merge_bool(value:boolean; base:integer; address:std_logic_vector; data:std_logic_vector(31 downto 0)) return boolean;
 procedure ss_install(signal target:inout std_logic_vector; base:integer; address:std_logic_vector; data:std_logic_vector(31 downto 0));
 procedure ss_install_bool(signal target:inout boolean; base:integer; address:std_logic_vector; data:std_logic_vector(31 downto 0));
end package;
package body sprite_state_pkg is
 function ss_bool(value:boolean) return std_logic_vector is variable r:std_logic_vector(0 downto 0);begin if value then r(0):='1';else r(0):='0';end if;return r;end;
 function ss_extract(value:std_logic_vector; base:integer; address:std_logic_vector) return std_logic_vector is
 variable r:std_logic_vector(31 downto 0):=(others=>'0');begin
 for b in value'range loop if (base+b)/32=to_integer(unsigned(address)) then r((base+b) mod 32):=value(b);end if;end loop;return r;end;
 function ss_merge(value:std_logic_vector; base:integer; address:std_logic_vector; data:std_logic_vector(31 downto 0)) return std_logic_vector is variable r:std_logic_vector(value'range):=value;begin
 for b in value'range loop if (base+b)/32=to_integer(unsigned(address)) then r(b):=data((base+b) mod 32);end if;end loop;return r;end;
 function ss_merge_bool(value:boolean; base:integer; address:std_logic_vector; data:std_logic_vector(31 downto 0)) return boolean is begin
 if base/32=to_integer(unsigned(address)) then return data(base mod 32)='1';else return value;end if;end;
 procedure ss_install(signal target:inout std_logic_vector; base:integer; address:std_logic_vector; data:std_logic_vector(31 downto 0)) is begin
 for b in target'range loop if (base+b)/32=to_integer(unsigned(address)) then target(b)<=data((base+b) mod 32);end if;end loop;end;
 procedure ss_install_bool(signal target:inout boolean; base:integer; address:std_logic_vector; data:std_logic_vector(31 downto 0)) is begin
 if base/32=to_integer(unsigned(address)) then target<=data(base mod 32)='1';end if;end;
end package body;
