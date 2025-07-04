`include "shift_reg.v"
`include "baudrate_generator.v"
`include "spi_slave_control_select.v"
`include "apb_slave_interface.v"

module spi_core (
    input         PCLK,
    input         PRESETn,
    input  [2:0]  PADDR,
    input         PWRITE,
    input         PSEL,
    input         PENABLE,
    input  [7:0]  PWDATA,
    input         miso,

    output        ss,
    output        sclk,
    output        spi_interrupt_request,
    output        mosi,
    output [7:0]  PRDATA,
    output        PREADY,
    output        PSLVERR,
    output receive_data
);

    // Internal wires
    wire tip;
    wire [1:0] spi_mode;
    wire spiswai, cpol, cpha, flag_high, flag_low, flags_high, flags_low;
    wire send_data, lsbfe, mstr;
    wire [11:0] baud_rate_div;
    wire [7:0] data_mosi, data_miso;
    wire [2:0] spr, sppr;

    // Baud Rate Generator
    baudrate_generator BAUD_GEN (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .spi_mode(spi_mode),
        .spiswai(spiswai),
        .sppr(sppr),
        .spr(spr),
        .cpol(cpol),
        .cpha(cpha),
        .ss(ss),
        .sclk(sclk),
        .flag_low(flag_low),
        .flag_high(flag_high),
        .flags_low(flags_low),
        .flags_high(flags_high),
        .baudratedivisor(baud_rate_div)
    );

    // APB Slave Interface
    apb_slave_interface APB_SLAVE (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(PADDR),
        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWDATA(PWDATA),
        .ss(ss),
        .miso_data(data_miso),
        .receive_data(receive_data),
        .tip(tip),
        .PRDATA(PRDATA),
        .mstr(mstr),
        .cpol(cpol),
        .cpha(cpha),
        .lsbfe(lsbfe),
        .spiswai(spiswai),
        .spi_interrupt_request(spi_interrupt_request),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .send_data(send_data),
        .mosi_data(data_mosi),
        .sppr(sppr),
        .spr(spr),
        .spi_mode(spi_mode)
    );

    // Slave Control Module
    spi_slave_control_select SPI_CTRL (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .mstr(mstr),
        .spiswai(spiswai),
        .spi_mode(spi_mode),
        .send_data(send_data),
        .BaudRateDivisor(baud_rate_div),
        .receive_data(receive_data),
        .ss(ss),
        .tip(tip)
    );

    // Shift Register
    shift_reg SHIFT_REG (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .ss(ss),
        .send_data(send_data),
        .receive_data(receive_data),
        .lsbfe(lsbfe),
        .cpha(cpha),
        .cpol(cpol),
        .flag_low(flag_low),
        .flag_high(flag_high),
        .flags_low(flags_low),
        .flags_high(flags_high),
        .data_mosi(data_mosi),
        .miso(miso),
        .mosi(mosi),
        .data_miso(data_miso)
    );

endmodule
