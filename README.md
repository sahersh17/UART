# UART Communication System (SystemVerilog)

A modular UART (Universal Asynchronous Receiver/Transmitter) written in SystemVerilog, with a parameterized baud rate, a shift-register transmitter, a 4-state FSM receiver, and a self-checking loopback testbench. Synthesized with Cadence Genus.

## Features

- **Three RTL modules:** transmitter, receiver, and a top-level wrapper that connects them in loopback
- **8-bit data path** with a standard 10-bit frame: 1 start bit, 8 data bits (LSB first), 1 stop bit
- **Configurable baud rate** through the `CLKS_PER_BIT` parameter (default `87`)
- **Mid-bit sampling** in the receiver: the start bit is confirmed at the middle of its period, and each data bit is sampled at the center of its period for noise margin
- **Self-checking testbench** that prints PASS/FAIL and dumps waveforms (`uart.vcd`) for debugging

## Architecture

```
            +---------------------- uart_top ----------------------+
            |                                                      |
 data_in -->|  +-------------+   tx_line   +-----------+           |--> data_out
 tx_start ->|  | transmitter |------------>| receiver  |           |--> rx_done
 clk, rst ->|  +-------------+             +-----------+           |
            |        |                                             |
            +--------|---------------------------------------------+
                     v
                  tx_done
```

### Frame format

```
idle  start   D0  D1  D2  D3  D4  D5  D6  D7  stop  idle
  1     0     .   .   .   .   .   .   .   .    1     1
```

### Baud rate

```
baud rate = clk frequency / CLKS_PER_BIT
```

For example, with `CLKS_PER_BIT = 87` and a 10 MHz clock, the baud rate is about 115,200. To change the baud rate, set `CLKS_PER_BIT` on both the transmitter and the receiver.

## Modules

### `transmitter`

Loads `{stop, data_in, start}` into a 10-bit shift register when `tx_start` is asserted, then shifts one bit out every `CLKS_PER_BIT` clock cycles. It pulses `tx_done` when the full frame has been sent.

### `receiver`

A 4-state FSM:

| State   | Behavior                                                                      |
|---------|-------------------------------------------------------------------------------|
| `IDLE`  | Waits for the line to go low (start bit)                                      |
| `START` | Waits half a bit period and confirms the line is still low, otherwise returns to `IDLE` |
| `DATA`  | Samples 8 bits at the center of each bit period, LSB first                    |
| `STOP`  | Waits out the stop bit, outputs `data_out`, and pulses `rx_done`              |

### `uart_top`

Connects the transmitter's `tx` output to the receiver's `rx` input for loopback testing.

## Ports (`uart_top`)

| Port       | Direction | Width | Description                         |
|------------|-----------|-------|-------------------------------------|
| `clk`      | input     | 1     | System clock                        |
| `rst`      | input     | 1     | Asynchronous active-high reset      |
| `tx_start` | input     | 1     | Starts transmission of `data_in`    |
| `data_in`  | input     | 8     | Byte to transmit                    |
| `tx_done`  | output    | 1     | Pulses when transmission completes  |
| `rx_done`  | output    | 1     | Pulses when a byte has been received|
| `data_out` | output    | 8     | Received byte                       |

## Repository structure

```
.
├── uart_top.v       # Top-level wrapper (TX -> RX loopback)
├── transmitter.v    # UART transmitter
├── receiver.v       # UART receiver (4-state FSM)
├── UART_TB.v        # Self-checking loopback testbench
└── README.md
```

## Simulation

Requires [Icarus Verilog](https://steveicarus.github.io/iverilog/) (or any Verilog simulator) and optionally [GTKWave](https://gtkwave.sourceforge.net/).

```bash
iverilog -o uart_sim UART_TB.v uart_top.v transmitter.v receiver.v
vvp uart_sim
gtkwave uart.vcd
```

Expected output:

```
Sent=a5  Received=a5
UART loopback SUCCESS
```

## Synthesis results

Synthesized with Cadence Genus on Linux at a 50 MHz clock constraint:

| Metric               | Result            |
|----------------------|-------------------|
| Total power          | 45.62 µW          |
| Data-path delay      | 299 ps            |
| Timing slack         | 14.616 ns         |
| Cell count           | 242               |
| Total area           | 3294.72 µm²       |

## Tools

SystemVerilog, Cadence Genus, Icarus Verilog, GTKWave, Linux

## Future improvements

- Test more data patterns (for example `0x00`, `0xFF`, `0x55`) and back-to-back transfers
- Add stop-bit validation and framing-error detection
- Add optional parity
- Add a TX/RX FIFO and separate baud-rate generator

## Contributors

Developed by a 4-member team at PES University.

- Saher Sharf ([@sahersh17](https://github.com/sahersh17))
- [Add teammates here]
