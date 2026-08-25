//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.12.01 (64-bit)
//IP Version: 1.1
//Part Number: GW5AT-LV60PG484AC1/I0
//Device: GW5AT-60
//Device Version: B
//Created Time: Wed Aug 19 17:16:32 2026

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_MULT_1212 your_instance_name(
        .dout(dout), //output [23:0] dout
        .a(a), //input [11:0] a
        .b(b), //input [11:0] b
        .clk(clk), //input clk
        .ce(ce), //input ce
        .reset(reset) //input reset
    );

//--------Copy end-------------------
