module SPI_MODULE(clk,rst_n,SS_n,MOSI,tx_valid,tx_data,MISO,rx_valid,rx_data);
    input MOSI , tx_valid , clk , rst_n , SS_n ;
    input [7:0] tx_data ;
    output reg  MISO , rx_valid ; 
    output reg [9:0] rx_data;
    /////////////////////////////////////////////
parameter IDLE = 3'b000;
parameter  CHK_CMD = 3'b001;
parameter  WRITE = 3'b010;
parameter  READ_ADD = 3'b011;
parameter  READ_DATA = 3'b100;
 (* fsm_encoding = "seq" *)
reg [2:0] cs , ns ;  
reg ADD_DATA_checker ; 
reg [3:0] counter1 ; 
reg [2:0] counter2 ; 
reg [9:0] bus ; 

 
always @(posedge clk)
begin
    if(~rst_n) 
        cs <= IDLE;
    else 
        cs <= ns ;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        counter1 <= 9;
        counter2 <= 7; 
        ADD_DATA_checker <= 1; 
        bus <= 0;
        rx_data <= 0;
        rx_valid <= 0; 
        MISO  <= 0; 
    end
    
    else begin
        if(cs == IDLE) begin
            rx_valid <= 0;
            counter1 <= 9 ; 
            counter2 <= 7 ; 
        end
        
        else if(cs == WRITE) begin
            if (counter1 >= 0)begin
                bus[counter1] <= MOSI;
                counter1 <= counter1 - 1;   
            end
            if(counter1 == 4'b1111) begin
                rx_valid = 1;
                rx_data <= bus ; 
            end
        end
       
        else if (cs == READ_ADD) begin
            if (counter1 >= 0)begin
                bus[counter1] <= MOSI;
                counter1 <= counter1 - 1;   
            end
            if(counter1 == 4'b1111) begin
                rx_valid <= 1;
                rx_data <= bus ;
                ADD_DATA_checker <= 0; 
            end
        end
 
        else if (cs == READ_DATA) begin
            if (counter1 >= 0)begin
                bus[counter1] <= MOSI;
                counter1 <= counter1 - 1;   
            end
            if(counter1 == 4'b1111) begin
                rx_valid <= 1;
                rx_data <= bus ; 
                counter1 <= 9 ; 
            end
            if(rx_valid  == 1) rx_valid <= 0; 
            if(tx_valid==1 && counter2 >=0)begin
                MISO <= tx_data[counter2] ; 
                counter2 <= counter2 - 1 ;
            end
            if(counter2 == 3'b111)begin
                ADD_DATA_checker <= 1; 
            end
        end
    end
end

always @(*) begin
    ns = cs ;
    case(cs)
        IDLE : begin
            if(SS_n)
                ns = IDLE;
            else    
                ns = CHK_CMD;
        end
        CHK_CMD : begin
            if(SS_n)
                ns = IDLE;
            else begin
                if((~SS_n) && (MOSI == 0))
                    ns = WRITE;
                else if ((~SS_n) && (MOSI == 1) && (ADD_DATA_checker == 1))
                    ns = READ_ADD;
                else if ((~SS_n) && (MOSI == 1) && (ADD_DATA_checker == 0))
                    ns = READ_DATA;
            end
        end
        WRITE : begin
            if(SS_n || counter1 == 4'b1111) 
                ns = IDLE;
            else 
                ns = WRITE;
        end
        READ_ADD : begin 
            if(SS_n || counter1 == 4'b1111)
                ns = IDLE;     
            else
                ns = READ_ADD;
        end
        READ_DATA : begin        
            if(SS_n)
                ns = IDLE;
            else
                ns = READ_DATA;
        end
    endcase
end

endmodule


