`default_nettype none
`timescale 1ns / 1ps

module tb;
    // Tiny Tapeout standard signals
    reg  clk;
    reg  rst_n;
    reg  ena;
    reg  [7:0] ui_in;
    reg  [7:0] uio_in;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    // 1. Instantiate the correct Top Module
    tt_um_pwm uut (
        .ui_in  (ui_in),    // Dedicated inputs
        .uo_out (uo_out),   // Dedicated outputs
        .uio_in (uio_in),   // IOs: Input path
        .uio_out(uio_out),  // IOs: Output path
        .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
        .ena    (ena),      // enable - goes high when design is selected
        .clk    (clk),      // clock
        .rst_n  (rst_n)     // not reset
    );

    initial begin
        $dumpfile("tb.fst");
        $dumpvars(0, tb);
        
        // --- THE MAGIC TRICK ---
        // Only apply this force during normal RTL simulation.
        // During Gate-Level (GL) simulation, internal wire names are destroyed 
        // by the synthesis tool, so this would cause an error.
`ifndef GL_TEST
        force uut.current_speed_prescaler = 24'd8;
`endif
    end
    // Do NOT generate a clock here.
    // Do NOT put test stimulus here.
    // Do NOT use $finish.
    // Cocotb (test.py) will handle all of that!
endmodule