//
//Written by GowinSynthesis
//Tool Version "V1.9.12.01 (64-bit)"
//IP Version: 1.0
//Sat Jul 25 02:22:29 2026

//Source file index table:
//file0 "\D:/Program/Gowin/Gowin_V1.9.12.01_x64/IDE/ipcore/DDR/data/ddr_138k.v"
`timescale 100 ps/100 ps
module GMII2RGMII (
  din,
  clk,
  q
)
;
input [7:0] din;
input clk;
output [3:0] q;
wire \oddr_gen[0].oddr_inst_1_Q1 ;
wire \oddr_gen[1].oddr_inst_1_Q1 ;
wire \oddr_gen[2].oddr_inst_1_Q1 ;
wire \oddr_gen[3].oddr_inst_1_Q1 ;
wire VCC;
wire GND;
  ODDR \oddr_gen[0].oddr_inst  (
    .Q0(q[0]),
    .Q1(\oddr_gen[0].oddr_inst_1_Q1 ),
    .D0(din[0]),
    .D1(din[4]),
    .TX(GND),
    .CLK(clk) 
);
  ODDR \oddr_gen[1].oddr_inst  (
    .Q0(q[1]),
    .Q1(\oddr_gen[1].oddr_inst_1_Q1 ),
    .D0(din[1]),
    .D1(din[5]),
    .TX(GND),
    .CLK(clk) 
);
  ODDR \oddr_gen[2].oddr_inst  (
    .Q0(q[2]),
    .Q1(\oddr_gen[2].oddr_inst_1_Q1 ),
    .D0(din[2]),
    .D1(din[6]),
    .TX(GND),
    .CLK(clk) 
);
  ODDR \oddr_gen[3].oddr_inst  (
    .Q0(q[3]),
    .Q1(\oddr_gen[3].oddr_inst_1_Q1 ),
    .D0(din[3]),
    .D1(din[7]),
    .TX(GND),
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
endmodule /* GMII2RGMII */
