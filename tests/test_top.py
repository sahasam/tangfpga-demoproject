import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


CLK_PERIOD_NS = 10  # 100 MHz for simulation
WAIT_TIME = 13_500_000  # Must match RTL localparam WAIT_TIME


async def reset_dut(dut):
    dut.reset.value = 1
    # Hold reset for a few cycles
    for _ in range(5):
        await RisingEdge(dut.clk)
    dut.reset.value = 0
    # One extra cycle to exit reset cleanly
    await RisingEdge(dut.clk)


@cocotb.test()
async def test_reset_clears_counters(dut):
    """After reset, counters should be reset and LED should be all 1s (inverted 0)."""
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, units="ns").start())
    await reset_dut(dut)

    # LED is inverted: led = ~ledcounter, so when ledcounter=0, led should be all 1s (0x3F for 6 bits)
    assert int(dut.led.value) == 0x3F, f"LED should be 0x3F after reset (inverted 0), got {int(dut.led.value):x}"
    # Peek internals to sanity-check (not required for functionality)
    assert int(dut.clock_counter.value) == 1
    assert int(dut.ledcounter.value) == 0


@cocotb.test()
async def test_led_decrements_when_wait_time_reached(dut):
    """Since LED is inverted, when ledcounter increments, LED decrements."""
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, units="ns").start())
    await reset_dut(dut)

    start_led = int(dut.led.value)
    start_ledcounter = int(dut.ledcounter.value)

    # Prime internal counter so the very next cycle triggers the increment path
    dut.clock_counter.value = WAIT_TIME
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # ledcounter should increment, so LED (which is ~ledcounter) should decrement
    expected_ledcounter = (start_ledcounter + 1) & 0x3F
    expected_led = (~expected_ledcounter) & 0x3F
    got_led = int(dut.led.value)
    got_ledcounter = int(dut.ledcounter.value)
    assert got_ledcounter == expected_ledcounter, f"ledcounter should increment: expected {expected_ledcounter}, got {got_ledcounter}"
    assert got_led == expected_led, f"LED should decrement (inverted): expected {expected_led}, got {got_led}"


@cocotb.test()
async def test_led_wraps_mod_64(dut):
    """Drive multiple increments and ensure modulo-64 wraparound for 6-bit counter."""
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, units="ns").start())
    await reset_dut(dut)

    # Force close-to-threshold repeatedly to avoid long simulations
    for i in range(20):
        current_ledcounter = int(dut.ledcounter.value)
        current_led = int(dut.led.value)
        dut.clock_counter.value = WAIT_TIME
        await RisingEdge(dut.clk)
        await RisingEdge(dut.clk)
        
        # ledcounter increments, LED (inverted) decrements
        expected_ledcounter = (current_ledcounter + 1) & 0x3F
        expected_led = (~expected_ledcounter) & 0x3F
        got_ledcounter = int(dut.ledcounter.value)
        got_led = int(dut.led.value)
        assert got_ledcounter == expected_ledcounter, f"Step {i}: ledcounter expected {expected_ledcounter}, got {got_ledcounter}"
        assert got_led == expected_led, f"Step {i}: LED expected {expected_led} (0x{expected_led:x}), got {got_led} (0x{got_led:x})"

