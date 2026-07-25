//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.12.01 (64-bit)
//IP Version: 1.1
//Part Number: GW5AT-LV60PG484AC1/I0
//Device: GW5AT-60
//Device Version: B
//Created Time: Fri Jul 24 20:18:11 2026

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	DDS_II_Top your_instance_name(
		.clk_i(clk_i), //input clk_i
		.rst_n_i(rst_n_i), //input rst_n_i
		.cosine_o(cosine_o), //output [11:0] cosine_o
		.sine_o(sine_o), //output [11:0] sine_o
		.data_valid_o(data_valid_o) //output data_valid_o
	);

//--------Copy end-------------------
