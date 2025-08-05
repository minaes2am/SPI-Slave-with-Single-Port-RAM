module test();
reg clk,rst_n,ss_n,mosi;
wire miso;
SPI_Wrapper  DUT(.clk(clk),.rst_n(rst_n),.MOSI(mosi),.MISO(miso),.ss_n(ss_n));
reg [9:0]temp;
integer i=0;

initial begin
clk=0;
forever
#1 clk=~clk;
end

initial begin
$readmemh("mem.dat",DUT.RAM.mem);
rst_n=0;
ss_n=1;
temp=0;
@(negedge clk);
temp=10'b0000_01010;
rst_n=1;


@(negedge clk)begin
ss_n=0;
end
@(negedge clk)begin
mosi=0;
end
for(i=10;i>0;i=i-1)begin
@(negedge clk)
	mosi=temp[i-1];
end

@(negedge clk)
ss_n=1;

@(negedge clk)
ss_n=0;
@(negedge clk)begin
mosi=0;

temp=10'b01000_01010;
end
for(i=10;i>0;i=i-1)begin
@(negedge clk)
	mosi=temp[i-1];
end
@(negedge clk)
ss_n=1;

@(negedge clk)
ss_n=0;
@(negedge clk)begin
mosi=1;

temp=10'b10000_01010;
end
for(i=10;i>0;i=i-1)begin
@(negedge clk)
	mosi=temp[i-1];
end
@(negedge clk)
ss_n=1;
@(negedge clk)
ss_n=1;

@(negedge clk)
ss_n=0;
@(negedge clk)begin
mosi=1;

temp=10'b11000_01010;
end
for(i=10;i>0;i=i-1)begin
@(negedge clk)
	mosi=temp[i-1];
end

repeat(25)@(negedge clk);
@(negedge clk)
ss_n=1;
repeat(25)@(negedge clk);
$stop;
end

initial begin
	$monitor("mosi=%b,miso=%b,SS_n=%b",mosi,miso,ss_n);
end
endmodule

