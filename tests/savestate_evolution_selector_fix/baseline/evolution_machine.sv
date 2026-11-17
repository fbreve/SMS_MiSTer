// Production Evolution mapper and Flash decoder, with system.vhd's exact
// Evolution mapper-word packing. Ordinary Sega banks are kept at reset values
// in this focused fixture; separate unchanged bank-controller regressions run.
module evolution_machine(input clk,reset_n,input[15:0]a,input[7:0]d,
 input mreq,iorq,rd,wr,m1,input set,input[95:0]ein,input[63:0]min,
 output[159:0]extra,output[63:0]mapped,output[23:0]physical,
 output[15:0]game,previous,output[7:0]mode,output launch);
 wire[7:0]b61,b62,g61,g62,p61,p62;wire[15:0]record;
 evolution_mapper mapper(.clk(clk),.reset_n(reset_n),.enable(1'b1),.cpu_a(a),
 .mreq_n(mreq),.iorq_n(iorq),.rd_n(rd),.wr_n(wr),.d_in(d),.m1_n(m1),
 .bank61(b61),.bank62(b62),.game_bank61(g61),.game_bank62(g62),
 .prev_game_bank61(p61),.prev_game_bank62(p62),.reg3ffe(mode),
 .reg8c(),.regcd(),.reg63(),.reg88(),.reg8d(),.reg8e(),.reg8f(),
 .launch_fetch_addr(record),.game_launch(launch),.ss_out(extra),
 .ss_in(ein),.ss_mapper_in(min),.ss_set(set));
 assign game={g62,g61};assign previous={p62,p61};
 assign mapped={record,8'd0,8'd1,8'd2,8'd3,mode,b61};
 evolution_rom_address address_decode(.evolution_game_bank61(g61),.evolution_game_bank62(g62),
 .evolution_prev_game_bank61(p61),.evolution_prev_game_bank62(p62),
 .evolution_launch_fetch_addr(record),.evolution_3ffe(mode),.mapper_evolution(1'b1),
 .rom_a_i({6'd0,a}),.rom_a(physical));
endmodule
