`timescale 1ns / 1ps

module tb_top;
    // Testbench signals
    reg clk;
    reg reset_n;
    reg [1:0] sw;
    reg btn_toggle;
    wire [15:0] led;

    // Instantiate the Top Module
    top uut (
        .CLK100MHZ(clk),
        .CPU_RESETN(reset_n),
        .sw(sw),
        .btn_toggle(btn_toggle),
        .LED(led)
    );

    // Generate a 100MHz clock (10ns period -> toggles every 5ns)
    always #5 clk = ~clk;

    initial begin
        // 1. Initialize Inputs
        clk = 0;
        reset_n = 0;   // Assert active-low reset
        sw = 2'b00;    // sw[0] = 0, sw[1] = 0 (50% amplitude)
        btn_toggle = 1;

        // --- THE MAGIC TRICK ---
        // Force the internal prescaler wire to a tiny value (10 clock cycles)
        // so we can actually see the waveform progress in a few microseconds!
        force uut.current_speed_prescaler = 24'd8;

        // 2. Release Reset after 100ns
        #100;
        reset_n = 1;

        // 3. Let it run for 100 microseconds to watch the 50% amplitude wave
        #10000000;

        // 4. Flip switch 1 UP to test 100% amplitude scaler
        sw[1] = 1;

        // 5. Let it run for another 100 microseconds
        #100000;

        // End simulation
        $finish;
    end

endmodule