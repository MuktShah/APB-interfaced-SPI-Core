module spi_slave_control_select (
    input  PCLK,
    input  PRESETn,
    input  mstr,
    input  spiswai,
    input  [1:0] spi_mode,
    input  send_data,
    input  [11:0] BaudRateDivisor,

    output reg receive_data,
    output reg ss,
    output tip
);

    reg rcv;
    reg [15:0] count;
    wire [15:0] target;

    assign target = BaudRateDivisor << 4;

    // SPI master mode condition
    wire w1 = mstr & ((spi_mode == 2'b00) || (spi_mode == 2'b01)) & (~spiswai);

    // Receive data register logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            receive_data <= 1'b0;
        else
            receive_data <= rcv;
    end

    // rcv signal logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            rcv <= 1'b0;
        else if (w1) begin
            if (send_data)
                rcv <= 1'b0;
            else if (count <= target - 1) begin
                if (count == target - 1)
                    rcv <= 1'b1;
            end else
                rcv <= 1'b0;
        end else
            rcv <= 1'b0;
    end

    // ss (slave select) logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            ss <= 1'b1;
        else if (w1) begin
            if (send_data || (count <= target - 1))
                ss <= 1'b0;  // Active low
            else
                ss <= 1'b1;
        end else
            ss <= 1'b1;
    end

    // tip signal = ~ss (transfer in progress)
    assign tip = ~ss;

    // Count logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            count <= 16'hFFFF;
        else if (w1) begin
            if (send_data)
                count <= 16'b0;
            else if (count <= target - 1)
                count <= count + 1'b1;
            else
                count <= 16'hFFFF;
        end else
            count <= 16'hFFFF;
    end

endmodule
