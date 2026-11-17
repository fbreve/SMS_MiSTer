const fs=require('fs'),p=require('path');let ports=fs.readFileSync(p.join(__dirname,'fm_v2/ports.svh'),'utf8');
ports=ports.replace('savestates dut(',"reg sc3000_mode=0,eeprom_present=0;\ncandidate_controller dut(").replace(".sc3000_mode(1'b0),.eeprom_present(1'b0)",'.sc3000_mode(sc3000_mode),.eeprom_present(eeprom_present)');
fs.writeFileSync(p.join(__dirname,'stress_ports.svh'),ports,{flag:'wx'});
