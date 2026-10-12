`timescale 1ns/1ps

module transmitter(clk,rst,tx_start,data_in,tx,tx_done);
parameter CLKS_PER_BIT = 87;

input clk,rst,tx_start;
input [7:0] data_in;
output reg tx,tx_done;

reg [3:0] bit_idx;
reg [12:0] clk_cnt;
reg [9:0] tx_shift;
reg tx_busy;

always @(posedge clk or posedge rst) begin
  if(rst) begin
    tx<=1;
    tx_done<=0;
    bit_idx<=0;
    clk_cnt<=0;
    tx_busy<=0;
  end else begin
    if(tx_start && !tx_busy) begin
      tx_shift<={1'b1,data_in,1'b0};
      tx_busy<=1;
      tx_done<=0;
      bit_idx<=0;
      clk_cnt<=0;
    end else if(tx_busy) begin
      if(clk_cnt<CLKS_PER_BIT-1)
        clk_cnt<=clk_cnt+1;
      else begin
        clk_cnt<=0;
        tx<=tx_shift[bit_idx];
        bit_idx<=bit_idx+1;
        if(bit_idx==9) begin
          tx_busy<=0;
          tx_done<=1;
          tx<=1;
        end
      end
    end else
      tx_done<=0;
  end
end
endmodule
