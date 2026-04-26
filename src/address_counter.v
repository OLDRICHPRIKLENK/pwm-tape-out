`timescale 1ns / 1ps

module address_counter (
    input  wire clk,
    input  wire rst,
    input  wire [23:0] speed_prescaler,
    output reg  [7:0] rom_addr
);

    reg [23:0] tick_counter;

    always @(posedge clk) begin
        if (rst) begin
            tick_counter <= 0;
            rom_addr <= 0;
        end else begin
            if (tick_counter >= speed_prescaler) begin
                tick_counter <= 0;
                rom_addr <= rom_addr + 1; // Step to the next sine wave point
            end else begin
                tick_counter <= tick_counter + 1;
            end
        end
    end
endmodule