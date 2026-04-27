/*
 * Copyright (c) 2024 Oldrich Priklenk
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

`timescale 1ns / 1ps

module tt_um_pwm (
    input  wire CLK100MHZ,
    input  wire CPU_RESETN, // Active-low reset
    input  wire [1:0] sw,   // sw[0]: reset, sw[1]: amplitude toggle
    input  wire btn_toggle, // Cycles through breathing speeds
    output wire [15:0] LED,
    output wire PWM_OUT_PIN  
);

    // Internal Wires
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

    // Output Mapping (Drive all 16 LEDs with the single PWM signal)
    assign LED = {16{pwm_signal}};
    assign PWM_OUT_PIN = pwm_signal;

    // --- INSTANTIATE PIPELINE ---

    button_ctrl u_btn_ctrl (
        .clk(CLK100MHZ),
        .rst(rst_active_high),
        .btn_in(btn_toggle),
        .speed_prescaler(current_speed_prescaler)
    );

    // Stage 1
    address_counter u_addr_counter (
        .clk(CLK100MHZ),
        .rst(rst_active_high),
        .speed_prescaler(current_speed_prescaler),
        .rom_addr(current_rom_addr)
    );

    // Stage 2
    waveform_bram u_bram (
        .clk(CLK100MHZ),
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
        .clk(CLK100MHZ),
        .rst(rst_active_high),
        .scaled_duty(final_scaled_duty),
        .pwm_out(pwm_signal)
    );

endmodule