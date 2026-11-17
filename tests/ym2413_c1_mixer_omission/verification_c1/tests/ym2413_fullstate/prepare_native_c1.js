const fs = require('fs');
const p = require('path');
const assert = require('assert');
const d = __dirname;

for (const lib of ['candidate', 'reference']) {
  const dest = p.join(d, 'native_' + lib);
  fs.rmSync(dest, { recursive: true, force: true });
  fs.mkdirSync(dest);
  for (const f of fs.readdirSync(p.join(d, lib)).filter(f => f.endsWith('.vhd'))) {
    let s = fs.readFileSync(p.join(d, lib, f), 'latin1');
    if (f === 'vm2413.vhd') {
      s = s.replace('package VM2413 is', `package VM2413 is
 signal verify_poison_en:std_logic:='0';
 signal verify_poison_mute:std_logic:='1';
 signal verify_poison_maddr:std_logic_vector(4 downto 0):=(others=>'0');
 signal verify_poison:std_logic_vector(13 downto 0):=(others=>'0');
 signal verify_poison_out:std_logic_vector(13 downto 0):=(others=>'0');`);
    }
    if (f === 'temporalmixer.vhd') {
      assert(/end process;/i.test(s));
      s = s.replace(/end process;/i, `if rising_edge(clk) and ss_hold='1' and verify_poison_en='1' then mute<=verify_poison_mute;maddr<=verify_poison_maddr;mix<=verify_poison;mixout<=verify_poison_out;end if;\nend process;`);
    }
    fs.writeFileSync(p.join(dest, f), s, 'latin1');
  }
}
console.log('Prepared native_candidate and native_reference for C1');

