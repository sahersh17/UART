`timescale 1ns/1ps

module uart_top(clk,rst,tx_start,data_in,tx_done,rx_done,data_out);
input clk,rst,tx_start;
input [7:0] data_in;
output tx_done,rx_done;
output [7:0] data_out;

wire tx_line;

transmitter txm(clk,rst,tx_start,data_in,tx_line,tx_done);
receiver rxm(clk,rst,tx_line,data_out,rx_done);

endmodule
