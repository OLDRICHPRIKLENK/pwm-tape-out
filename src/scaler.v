`timescale 1ns / 1ps

module amplitude_scaler (
    input  wire [7:0] raw_duty,
    input  wire [7:0] amplitude, // 255 = 100% volume, 128 = 50% volume, etc.
    output wire [7:0] scaled_duty
);

    // 8-bit x 8-bit multiplication yields a 16-bit result.
    // The synthesis tool will automatically map this to a DSP48 slice.
    wire [15:0] mult_result;
    
    assign mult_result = raw_duty * amplitude;

    // "Free" Division by 256: Take the top 8 bits, discard the bottom 8 bits.
    assign scaled_duty = mult_result[15:8];

endmodule