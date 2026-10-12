`timescale 1ns/1ps

module UART_TB;
reg clk;
reg rst;
reg tx_start;
reg [7:0] data_in;
wire [7:0] data_out;
wire tx_done;
wire rx_done;

uart_top dut(clk,rst,tx_start,data_in,tx_done,rx_done,data_out);

always #5 clk=~clk;

initial begin
  clk=0;
  rst=1;
  tx_start=0;
  data_in=8'h00;
  #20 rst=0;

  #50 data_in=8'hA5;
  tx_start=1;
  #10 tx_start=0;

  wait(rx_done);
  #50;
  $display("Sent=%h  Received=%h",data_in,data_out);
  if(data_out==data_in)
    $display("UART loopback SUCCESS");
  else
    $display("UART loopback FAIL");
  #100;
  $finish;
end

initial begin
  $dumpfile("uart.vcd");
  $dumpvars(0,UART_TB);
end
endmodule
