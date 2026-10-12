# UART
Designed a modular UART in SystemVerilog with a shift-register transmitter, a 4-state FSM receiver using mid-bit sampling, and a parameterized baud rate (CLKS_PER_BIT). Verified with a self-checking loopback testbench and synthesized in Cadence Genus: 45.62 µW, 299 ps data-path delay, and 14.616 ns slack at 50 MHz.
