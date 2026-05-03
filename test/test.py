import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer

@cocotb.test()
async def test_pwm(dut):
    # Generate a 100MHz clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Initialize inputs
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    
    # Release Reset after 100ns
    await Timer(100, units="ns")
    dut.rst_n.value = 1

    # Replicate your switch logic. If sw[1:0] is mapped to ui_in[2:1]:
    dut.ui_in.value = 0b00000000 # Set switches to 00
    await Timer(100, units="us") # Wait 100 microseconds
    
    dut.ui_in.value = 0b00000010 # Flip switch 1 UP
    await Timer(100, units="us")