`timescale 1ns / 1ps

module pwm_generator (
    input  wire clk,
    input  wire rst,
    input  wire [7:0] scaled_duty,
    output reg  pwm_out
);

    reg [7:0] carrier_counter;

    always @(posedge clk) begin
        if (rst) begin
            carrier_counter <= 0;
            pwm_out <= 0;
        end else begin
            // Free-running 8-bit counter wraps automatically at 255
            carrier_counter <= carrier_counter + 1;
            
            // Standard PWM comparison
            if (carrier_counter < scaled_duty)
                pwm_out <= 1'b1;
            else
                pwm_out <= 1'b0;
        end
    end
endmodule