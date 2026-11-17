module pause_fixture(input clk,reset_n,systeme,joy8_sig,VBlank,ss_freeze,input preserve,output reg se_paused,output reg se_pause_pending,output reg se_unpause_pending);reg joy8_r,VBlank_r,ss_freeze_r;wire ss_unfreeze=ss_freeze_r&~ss_freeze;always@(posedge clk)ss_freeze_r<=ss_freeze;
always @(posedge clk) begin
	// Current host input is sampled even during transport. Edges inside that
	// interval are consumed without queuing a toggle; a new post-release edge
	// is accepted normally. Pending toggles belong to the current UI phase.
	joy8_r   <= joy8_sig;
	VBlank_r <= VBlank;
	if (!reset_n | ~systeme) begin
		se_paused          <= 0;
		se_pause_pending   <= 0;
		se_unpause_pending <= 0;
	end else if (~ss_freeze) begin
		// Rising edge of pause button (not during savestates, not already pending)
		if (~joy8_r & joy8_sig & ~ss_freeze & ~se_unpause_pending & ~se_pause_pending) begin
			if (se_paused)
				// Defer CPU release to the next VBlank rising edge so the game's
				// VBlank handler always runs *during* VBlank, not active display.
				se_unpause_pending <= 1;
			else
				// Defer CPU freeze to the next VBlank fall (y=0) so the game's
				// VBlank handler always completes before freezing; prevents
				// tile/sprite corruption from a partially-updated VDP state.
				se_pause_pending <= 1;
		end
		// Ignore transport-only beam edges, including the release handoff.
		// VBlank fall (y=0): apply the deferred pause
		if (~ss_unfreeze & se_pause_pending & VBlank_r & ~VBlank) begin
			se_paused        <= 1;
			se_pause_pending <= 0;
		end
		// VBlank rising edge: release the deferred unpause
		if (~ss_unfreeze & se_unpause_pending & ~VBlank_r & VBlank) begin
			se_paused          <= 0;
			se_unpause_pending <= 0;
		end
	end
end
endmodule
