// Nuked-SMS backend integration skeleton.
//
// This module intentionally contains only the adapter boundary. The actual
// cycle-accurate implementation is vendored from nukeykt/Nuked-SMS-FPGA.
// Keep this backend isolated from the existing SMS system until it builds and
// passes the SMS VDP tests.

module nuked_sms_backend #(
    parameter bit ENABLE = 1'b0
) (
    input  logic        clk,
    input  logic        reset,
    input  logic [15:0] cart_addr,
    input  logic        cart_cs,
    input  logic        cart_oe,
    input  logic        cart_wr,
    input  logic [7:0]  cart_din,
    output logic [7:0]  cart_dout,
    output logic [12:0] ram_addr,
    output logic [7:0]  ram_dout,
    output logic        ram_we,
    input  logic [7:0]  ram_din,
    input  logic [12:0] bios_addr,
    input  logic [7:0]  bios_din,
    output logic [7:0]  video_r,
    output logic [7:0]  video_g,
    output logic [7:0]  video_b,
    output logic        video_hs,
    output logic        video_vs,
    output logic signed [17:0] audio_l,
    output logic signed [17:0] audio_r
);

    // The actual sms_board instance will be connected here after the Nuked
    // HDL sources are vendored into rtl/nuked/.
    always_comb begin
        cart_dout = 8'hFF;
        ram_addr  = '0;
        ram_dout  = '0;
        ram_we    = 1'b0;
        video_r   = '0;
        video_g   = '0;
        video_b   = '0;
        video_hs  = 1'b0;
        video_vs  = 1'b0;
        audio_l   = '0;
        audio_r   = '0;
    end

endmodule
