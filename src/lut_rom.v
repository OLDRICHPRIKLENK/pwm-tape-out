`timescale 1ns / 1ps

module waveform_bram (
    input  wire clk,
    input  wire [7:0] rom_addr,
    output reg  [7:0] raw_duty
);

    // Declare a 256x8 memory array
    reg [7:0] memory [0:255];

    // Load the pre-calculated sine wave from a file during synthesis
    initial begin
        $readmemh("sawtooth.mem", memory); 
    end

    // Synchronous read (Mandatory for inferring Block RAM)
    always @(posedge clk) begin
        raw_duty <= memory[rom_addr];
    end

endmodule