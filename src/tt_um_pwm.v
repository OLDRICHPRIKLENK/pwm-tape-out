/*
 * Copyright (c) 2024 Oldrich Priklenk
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`timescale 1ns / 1ps

module tt_um_pwm (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // ==========================================
    // 1. Map Tiny Tapeout pins to your logic
    // ==========================================
    wire [1:0] sw         = ui_in[1:0]; // Use ui_in[0] and ui_in[1] for your switches
    wire       btn_toggle = ui_in[2];   // Use ui_in[2] for your button
    wire       CPU_RESETN = rst_n;      // Map the standard active-low reset

    // Tie off unused bidirectional pins (Required by Tiny Tapeout)
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // ==========================================
    // 2. Internal Wires
    // ==========================================
    wire rst_active_high;
    wire [23:0] current_speed_prescaler;
    wire [7:0]  current_rom_addr;
    wire [7:0]  raw_waveform_duty;
    wire [7:0]  current_amplitude;
    wire [7:0]  final_scaled_duty;
    wire        pwm_signal;

    // Standardize reset
    assign rst_active_high = sw[0] || !CPU_RESETN;

    // Amplitude Control (sw[1] DOWN = 50% brightness, UP = 100% brightness)
    assign current_amplitude = (sw[1]) ? 8'd255 : 8'd128;

    // Output Mapping (Drive all 8 output pins with the single PWM signal)
    // Note: Tiny Tapeout only has 8 output pins, so we dropped the 16-bit LED requirement.
    assign uo_out = {8{pwm_signal}};

    // ==========================================
    // 3. Instantiate Pipeline
    // ==========================================

    button_ctrl u_btn_ctrl (
        .clk(clk),                // Fixed from CLK100MHZ
        .rst(rst_active_high),
        .btn_in(btn_toggle),
        .speed_prescaler(current_speed_prescaler)
    );

    // Stage 1
    address_counter u_addr_counter (
        .clk(clk),                // Fixed from CLK100MHZ
        .rst(rst_active_high),
        .speed_prescaler(current_speed_prescaler),
        .rom_addr(current_rom_addr)
    );

    // Stage 2
    waveform_bram u_bram (
        .clk(clk),                // Fixed from CLK100MHZ
        .rom_addr(current_rom_addr),
        .raw_duty(raw_waveform_duty)
    );

    // Stage 3
    amplitude_scaler u_scaler (
        .raw_duty(raw_waveform_duty),
        .amplitude(current_amplitude),
        .scaled_duty(final_scaled_duty)
    );

    // Stage 4
    pwm_generator u_pwm (
        .clk(clk),                // Fixed from CLK100MHZ
        .rst(rst_active_high),
        .scaled_duty(final_scaled_duty),
        .pwm_out(pwm_signal)
    );
endmodule