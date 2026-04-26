`timescale 1ns / 1ps

module button_ctrl (
    input  wire clk,
    input  wire rst,
    input  wire btn_in,
    output reg  [23:0] speed_prescaler
);

    // Debouncing Logic
    reg [15:0] debounce_counter;
    reg btn_state, btn_prev;
    wire btn_pressed;

    always @(posedge clk) begin
        if (rst) begin
            debounce_counter <= 0;
            btn_state <= 0;
            btn_prev <= 0;
        end else begin
            if (btn_in !== btn_state) begin
                debounce_counter <= debounce_counter + 1;
                `ifdef SIMULATION
                if (debounce_counter == 16'h000F) begin // Very short for simulation
                `else
                if (debounce_counter == 16'hFFFF) begin // ~0.65ms for hardware
                `endif
                    btn_state <= btn_in;
                    debounce_counter <= 0;
                end
            end else begin
                debounce_counter <= 0;
            end
            btn_prev <= btn_state;
        end
    end

    // Edge Detection
    assign btn_pressed = (btn_state == 1'b1 && btn_prev == 1'b0);

    // Speed FSM (Controls the waveform animation speed)
    reg [1:0] speed_state;

    always @(posedge clk) begin
        if (rst) begin
            speed_state <= 0;
            speed_prescaler <= 24'd10; // Default fast speed
        end else if (btn_pressed) begin
            speed_state <= speed_state + 1;
            case (speed_state + 1)
                2'd0: speed_prescaler <= 24'd256;   // ~2.56 µs per step (Fastest valid PWM)
                2'd1: speed_prescaler <= 24'd500;   // ~5.00 µs per step
                2'd2: speed_prescaler <= 24'd750;   // ~7.50 µs per step
                2'd3: speed_prescaler <= 24'd1000;  // ~10.0 µs per step
            endcase
        end
    end
endmodule