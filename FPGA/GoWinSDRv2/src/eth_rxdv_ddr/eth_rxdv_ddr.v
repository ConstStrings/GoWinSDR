//
//Written by GowinSynthesis
//Tool Version "V1.9.12.01 (64-bit)"
//IP Version: 1.0
//Sat Jul 25 17:54:01 2026

//Source file index table:
//file0 "\D:/Program/Gowin/Gowin_V1.9.12.01_x64/IDE/ipcore/DDR/data/ddr_138k.v"
`timescale 100 ps/100 ps
module eth_rxdv_ddr (
  din,
  clk,
  q
)
;
input [0:0] din;
input clk;
output [1:0] q;
wire VCC;
wire GND;
  IDDR \iddr_gen[0].iddr_inst  (
    .Q0(q[0]),
    .Q1(q[1]),
    .D(din[0]),
    .CLK(clk) 
);
  VCC VCC_cZ (
    .V(VCC)
);
  GND GND_cZ (
    .G(GND)
);
  GSR GSR (
    .GSRI(VCC) 
);
endmodule /* eth_rxdv_ddr */
