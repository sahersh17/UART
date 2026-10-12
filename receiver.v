`timescale 1ns/1ps

module receiver(clk, rst, rx, data_out, rx_done);
parameter CLKS_PER_BIT = 87;

input clk, rst, rx;
output reg [7:0] data_out;
output reg rx_done;

reg [3:0] bit_idx;
reg [12:0] clk_cnt;
reg [7:0] rx_shift;
reg rx_busy;
reg start_detected;
reg [1:0] state;

localparam IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;

always @(posedge clk or posedge rst) begin
  if (rst) begin
    data_out <= 0;
    rx_done <= 0;
    bit_idx <= 0;
    clk_cnt <= 0;
    rx_busy <= 0;
    start_detected <= 0;
    state <= IDLE;
  end else begin
    case (state)
      IDLE: begin
        rx_done <= 0;
        if (rx == 0) begin
          state <= START;
          clk_cnt <= 0;
        end
      end

      START: begin
        if (clk_cnt == (CLKS_PER_BIT/2)) begin
          if (rx == 0) begin
            clk_cnt <= 0;
            bit_idx <= 0;
            state <= DATA;
          end else
            state <= IDLE;
        end else
          clk_cnt <= clk_cnt + 1;
      end

      DATA: begin
        if (clk_cnt < CLKS_PER_BIT - 1)
          clk_cnt <= clk_cnt + 1;
        else begin
          clk_cnt <= 0;
          rx_shift[bit_idx] <= rx;
          if (bit_idx < 7)
            bit_idx <= bit_idx + 1;
          else
            state <= STOP;
        end
      end

      STOP: begin
        if (clk_cnt < CLKS_PER_BIT - 1)
          clk_cnt <= clk_cnt + 1;
        else begin
          data_out <= rx_shift;
          rx_done <= 1;
          state <= IDLE;
        end
      end
    endcase
  end
end
endmodule

