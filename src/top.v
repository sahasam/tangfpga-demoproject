module top (
    input wire clk,
    input wire reset,
    output wire [5:0] led
);  

    localparam WAIT_TIME = 13500000; // 13.5MHz

    reg [31:0] clock_counter;
    reg [5:0] ledcounter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clock_counter <= 1;
            ledcounter <= 0;
        end else begin
            if (clock_counter >= WAIT_TIME) begin
                clock_counter <= 1;
                ledcounter <= ledcounter + 1;
            end else begin
                clock_counter <= clock_counter + 1;
            end
        end
    end

    assign led = ~ledcounter;
endmodule