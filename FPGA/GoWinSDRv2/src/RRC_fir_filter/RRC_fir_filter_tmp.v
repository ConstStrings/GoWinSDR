//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.12.01 (64-bit)
//IP Version: 2.5
//Part Number: GW5AT-LV60PG484AC1/I0
//Device: GW5AT-60
//Device Version: B
//Created Time: Mon Aug  3 08:49:31 2026

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	RRC_FIR_Filter_Top your_instance_name(
		.clk(clk), //input clk
		.rstn(rstn), //input rstn
		.fir_rfi_o(fir_rfi_o), //output fir_rfi_o
		.fir_valid_i(fir_valid_i), //input fir_valid_i
		.fir_sync_i(fir_sync_i), //input fir_sync_i
		.fir_data_i(fir_data_i), //input [11:0] fir_data_i
		.fir_valid_o(fir_valid_o), //output fir_valid_o
		.fir_sync_o(fir_sync_o), //output fir_sync_o
		.fir_data_o(fir_data_o) //output [26:0] fir_data_o
	);

//--------Copy end-------------------
