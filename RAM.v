module RAM_MODULE (clk,rst_n,rx_valid,din,dout,tx_valid);

 parameter MEM_DEPTH = 256;
 parameter ADDR_SIZE = 8;

 input clk;
 input rst_n;
 input rx_valid;
 input [9:0] din;

 output reg [7:0] dout;
 output reg tx_valid;

reg [ADDR_SIZE-1:0] mem [MEM_DEPTH-1:0]; 
reg [7:0] addr_wr; 
reg [7:0] addr_re;  


always @(posedge clk) begin  
    if (!rst_n) begin   
        dout <= 8'b0;
        tx_valid <= 1'b0;
        addr_wr <= 8'b0;
        addr_re <= 8'b0;
    end else begin
        if (rx_valid) begin 
            case (din[9:8])
                2'b00: begin
                    addr_wr <= din[7:0]; 
                    tx_valid <= 1'b0;
                end
                2'b01: begin
                    mem[addr_wr] <= din[7:0];
                    tx_valid <= 1'b0;
                end
                2'b10: begin
                    addr_re <= din[7:0]; 
                    tx_valid <= 1'b0;
                end
                2'b11: begin 
                    dout <= mem[addr_re];
                    tx_valid <= 1'b1;
                end
            endcase
        end
    end
end
endmodule