// Production Evolution mapper and Flash decoder, with system.vhd's exact
// Evolution mapper-word packing. Ordinary Sega banks are kept at reset values
// in this focused fixture; separate unchanged bank-controller regressions run.
module evolution_banked_machine(input clk,reset_n,input[15:0]a,input[7:0]d,
 input mreq,iorq,rd,wr,m1,input set,input[159:0]ein,input[63:0]min,
 output[159:0]extra,output[63:0]mapped,output[23:0]physical,
 output[15:0]game,previous,output[7:0]mode,output launch,output[5:0]phase);
 wire[7:0]b0,b1,b2,b3;wire[7:0]b61,b62,g61,g62,p61,p62;wire[15:0]record;
 evolution_mapper mapper(.clk(clk),.reset_n(reset_n),.enable(1'b1),.cpu_a(a),
 .mreq_n(mreq),.iorq_n(iorq),.rd_n(rd),.wr_n(wr),.d_in(d),.m1_n(m1),
 .bank61(b61),.bank62(b62),.game_bank61(g61),.game_bank62(g62),
 .prev_game_bank61(p61),.prev_game_bank62(p62),.reg3ffe(mode),
 .reg8c(),.regcd(),.reg63(),.reg88(),.reg8d(),.reg8e(),.reg8f(),
 .launch_fetch_addr(record),.game_launch(launch),.ss_out(extra),
 .debug_phase(phase),.ss_in(ein),.ss_mapper_in(min),.ss_set(set));
 assign game={g62,g61};assign previous={p62,p61};
 assign mapped={record,b0,b1,b2,b3,mode,b61};
 evolution_rom_address address_decode(.evolution_game_bank61(g61),.evolution_game_bank62(g62),
 .evolution_prev_game_bank61(p61),.evolution_prev_game_bank62(p62),
 .evolution_launch_fetch_addr(record),.evolution_3ffe(mode),.mapper_evolution(1'b1),
 .rom_a_i(a[15:14]==2?{b2,a[13:0]}:{6'd0,a}),.rom_a(physical));
mapper_ctrl banks(.RESET_n(reset_n),.clk_sys(clk),.evolution_game_launch(launch),.mapper_set(set),.mapper_evolution(1'b1),.mapper_in(min),.mapper_janggun(1'b0),.systeme(1'b0),.bootloader_n(1'b1),.mapper_wonderkid(1'b0),.mapper_lock(1'b0),.detect_codies_static(1'b0),.mapper_codies_force(1'b0),.mapper_eeprom(1'b0),.mapper_zemina_force(1'b0),.mapper_nemesis_auto(1'b0),.rom_size_pages(8'hff),.ce_z80(1'b1),.WR_n(wr),.MREQ_n(mreq),.A(a),.ss_freeze(1'b0),.D_in(d),.sc3000_en(1'b0),.mapper_castle(1'b0),.mapper_linear(1'b0),.mapper_dahjee_a(1'b0),.mapper_sega_locked(1'b0),.use_zem(1'b0),.mapper_manual_force(1'b1),.sega_mapper_write_seen(1'b1),.bank0_out(b0),.bank1_out(b1),.bank2_out(b2),.bank3_out(b3));
endmodule
