module UART_transmitter(
            input clk,
            input TxD_start,
            input [7:0] TxD_data,
            output wire TxD,
            output reg TxD_done//Txdone,
           
);

// Assert TxD_start for (at least) one clock cycle to start transmission of TxD_data
// TxD_data is latched so that it doesn't have to stay valid while it is being sent

parameter ClkFrequency = 100000000;         // 100MHz
parameter Baud = 115200;
wire TxD_busy;

/////////////////////////////////////Baud tick Generartor/////////////////////
wire BitTick;
BaudTickGen #(ClkFrequency, Baud) tickgen(.clk(clk), .enable(TxD_busy), .tick(BitTick));
//`endif
//////////////////////////////////////////////////////////////////
reg [3:0] TxD_state = 0;
assign TxD_ready = (TxD_state==0);
assign TxD_busy = ~TxD_ready;
reg [7:0] TxD_shift = 0;

always @(posedge clk)
begin
            if(TxD_ready & TxD_start)
                        begin TxD_shift <= TxD_data; end
            else
            if(TxD_state[3] & BitTick)                                                                                         //Data bits(byte) sending
                        begin TxD_shift <= (TxD_shift >> 1); end                //input byte is sening in each clock cycle one by one
            case(TxD_state)                                                                                                                                  //counting each bit
                        4'b0000 : if(TxD_start)
                                                            begin
                                                            TxD_state <= 4'b0100;
                                                            TxD_done<=0;
                                                            end                                                                                         
                        4'b0100: if(BitTick) TxD_state <= 4'b1000;  // start bit
                        4'b1000: if(BitTick) TxD_state <= 4'b1001;  // bit 0
                        4'b1001: if(BitTick) TxD_state <= 4'b1010;  // bit 1
                        4'b1010: if(BitTick) TxD_state <= 4'b1011;  // bit 2
                        4'b1011: if(BitTick) TxD_state <= 4'b1100;  // bit 3
                        4'b1100: if(BitTick) TxD_state <= 4'b1101;  // bit 4
                        4'b1101: if(BitTick) TxD_state <= 4'b1110;  // bit 5
                        4'b1110: if(BitTick) TxD_state <= 4'b1111;  // bit 6
                        4'b1111: if(BitTick) TxD_state <= 4'b0010;  // bit 7
                        4'b0010: if(BitTick) TxD_state <= 4'b0011;  // stop1
                        4'b0011: if(BitTick)                                                                                          // stop2
                                                            begin
                                                                        TxD_state <= 4'b0000;
                                                                        TxD_done<=1; 
                                                            end
                        default: if(BitTick) TxD_state <= 4'b0000;
            endcase
end

assign TxD = (TxD_state<4) | (TxD_state[3] & TxD_shift[0]);  // put together the start, data and stop bits
endmodule
