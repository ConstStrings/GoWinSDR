//
//Written by GowinSynthesis
//Tool Version "V1.9.12.01 (64-bit)"
//IP Version: 1.0
//Sat Jul 25 17:50:50 2026

//Source file index table:
//file0 "\D:/Program/Gowin/Gowin_V1.9.12.01_x64/IDE/ipcore/DDR/data/ddr_138k.v"
`timescale 100 ps/100 ps
module eth_DDR (
  din,
  clk,
  q
)
;
input [3:0] din;
input clk;
output [7:0] q;
wire VCC;
wire GND;
  IDDR \iddr_gen[0].iddr_inst  (
    .Q0(q[0]),
    .Q1(q[4]),
    .D(din[0]),
    .CLK(clk) 
);
  IDDR \iddr_gen[1].iddr_inst  (
    .Q0(q[1]),
    .Q1(q[5]),
    .D(din[1]),
    .CLK(clk) 
);
  IDDR \iddr_gen[2].iddr_inst  (
    .Q0(q[2]),
    .Q1(q[6]),
    .D(din[2]),
    .CLK(clk) 
);
  IDDR \iddr_gen[3].iddr_inst  (
    .Q0(q[3]),
    .Q1(q[7]),
    .D(din[3]),
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
endmodule /* eth_DDR */
