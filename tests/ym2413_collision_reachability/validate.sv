module validate;
`include "validator_function.svh"
function [31:0] legacy_word;
        input [7:0] address;
        begin
            legacy_word=0;
            case(address)
            // F01_LEGACY_WORDS
            8'd78: legacy_word=32'h47;
            8'd88: legacy_word=32'h8000;
            8'd90: legacy_word=32'h3ffff;
            8'd101: legacy_word=32'h1;


            default: legacy_word=0;
            endcase
        end
    endfunction
reg[31:0] words[0:103];integer fd,n,i,k,checked,rejected_output,rejected_register,coherent_count,guarded_count;reg[31:0] value;string filename;
task check_file(input string file_name,input integer cohort);
begin fd=$fopen(file_name,"r");if(!fd)$fatal(1,"cannot open %s",file_name);n=0;
while(!$feof(fd))begin
 k=$fscanf(fd,"%h",value);
 if(k==1)begin
 words[0]=value;if(!fm_word_valid(0,value))$fatal(1,"word zero rejected");
 for(i=1;i<104;i=i+1)begin k=$fscanf(fd,"%h",value);if(k==1)begin words[i]=value;if(!fm_word_valid(i,value))$fatal(1,"production validator rejected %s image %0d word %0d value %h",file_name,n,i,value);end else $fatal(1,"partial image");end
 n=n+1;checked=checked+1;
 if(cohort==1)begin if(words[100][1]&&words[78][1:0]!=0)$fatal(1,"coherent producer violates candidate stage guard");coherent_count=coherent_count+1;end
 else if(cohort==2)begin if(words[100][1]&&words[78][1:0]!=0)$fatal(1,"guard cohort violates its proposed condition");guarded_count=guarded_count+1;end
 else begin if(words[100][1]&&words[78][1:0]!=0)rejected_output=rejected_output+1;if(words[83][4]&&words[78][1:0]!=0&&words[78][1:0]!=3)rejected_register=rejected_register+1;end
 end
end
$fclose(fd);$display("PASS exact production validator file=%s images=%0d",file_name,n);
end endtask
initial begin checked=0;rejected_output=0;rejected_register=0;coherent_count=0;guarded_count=0;
for(integer c=0;c<4;c=c+1)check_file($sformatf("payload_%0d_0.hex",c),0);
check_file("allpayload_10_0.hex",1);
check_file("allpayload_15_0.hex",2);
for(integer j=76;j<104;j=j+1)begin value=0;case(j)78:value='h47;88:value='h8000;90:value='h3ffff;101:value=1;endcase;if(legacy_word(j)!==value)$fatal(1,"legacy fallback mismatch");end
$display("PASS validator checked=%0d coherent=%0d guard_cohort=%0d directed_output_guard_rejections=%0d directed_register_stage_rejections=%0d legacy_words=28",checked,coherent_count,guarded_count,rejected_output,rejected_register);$finish;
end endmodule
