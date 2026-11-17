function [12:0]key_address(input[15:0]a,input bit op);key_address={!op,a[15:10],a[8],a[6],a[4],a[2:0]};endfunction
function[7:0]key_byte(input[12:0]a);key_byte=(a*37)^(a>>4)^8'ha5;endfunction
function[7:0]xor_byte(input[6:0]a);xor_byte=(a*73)^(a>>2)^8'h5a;endfunction
function[7:0]swap_byte(input[6:0]a);swap_byte=(a*7+3)%24;endfunction
function[6:0]sega_index(input[15:0]a,input bit op);sega_index={a[14],a[12],a[9],a[6],a[3],a[0],!op};endfunction
function[7:0]swap_bits(input[7:0]v,input[7:0]mode);
begin
 // Explicit four-bit permutations, matching production bswp order.
 case(mode)
 0:swap_bits={v[7],v[6],v[5],v[4],v[3],v[2],v[1],v[0]};
 1:swap_bits={v[7],v[4],v[5],v[6],v[3],v[2],v[1],v[0]};
 2:swap_bits={v[7],v[2],v[5],v[4],v[3],v[6],v[1],v[0]};
 3:swap_bits={v[7],v[0],v[5],v[4],v[3],v[2],v[1],v[6]};
 4:swap_bits={v[7],v[6],v[5],v[2],v[3],v[4],v[1],v[0]};
 5:swap_bits={v[7],v[6],v[5],v[0],v[3],v[2],v[1],v[4]};
 6:swap_bits={v[7],v[6],v[5],v[4],v[3],v[0],v[1],v[2]};
 7:swap_bits={v[7],v[2],v[5],v[6],v[3],v[4],v[1],v[0]};
 8:swap_bits={v[7],v[4],v[5],v[2],v[3],v[6],v[1],v[0]};
 9:swap_bits={v[7],v[4],v[5],v[6],v[3],v[0],v[1],v[2]};
 10:swap_bits={v[7],v[6],v[5],v[0],v[3],v[4],v[1],v[2]};
 11:swap_bits={v[7],v[0],v[5],v[6],v[3],v[4],v[1],v[2]};
 12:swap_bits={v[7],v[4],v[5],v[0],v[3],v[6],v[1],v[2]};
 13:swap_bits={v[7],v[0],v[5],v[4],v[3],v[6],v[1],v[2]};
 14:swap_bits={v[7],v[6],v[5],v[2],v[3],v[0],v[1],v[4]};
 15:swap_bits={v[7],v[2],v[5],v[6],v[3],v[0],v[1],v[4]};
 16:swap_bits={v[7],v[0],v[5],v[6],v[3],v[2],v[1],v[4]};
 17:swap_bits={v[7],v[2],v[5],v[0],v[3],v[6],v[1],v[4]};
 18:swap_bits={v[7],v[0],v[5],v[2],v[3],v[6],v[1],v[4]};
 19:swap_bits={v[7],v[4],v[5],v[2],v[3],v[0],v[1],v[6]};
 20:swap_bits={v[7],v[2],v[5],v[4],v[3],v[0],v[1],v[6]};
 21:swap_bits={v[7],v[4],v[5],v[0],v[3],v[2],v[1],v[6]};
 22:swap_bits={v[7],v[2],v[5],v[0],v[3],v[4],v[1],v[6]};
 23:swap_bits={v[7],v[0],v[5],v[2],v[3],v[4],v[1],v[6]};
 default:swap_bits=0;
 endcase
end endfunction

