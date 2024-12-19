module tag_array_wrapper (
  input CK,
  input CS,
  input OE,
  input WEB,
  input [4:0] A,
  input [22:0] DI,
  output [22:0] DO
);
  logic [31:0] BWEB;
  logic [31:0] D;
  logic [31:0] Q;


  assign D = {9'h0,DI};
  assign DO = Q[22:0] ;
  assign BWEB = (WEB) ?  32'hffffffff : 32'h0;

  TS1N16ADFPCLLLVTA128X64M4SWSHOD_tag_array i_tag_array1 (
    .CLK        (CK),
    .A          (A),
    .CEB        (CS),  // chip enable, active LOW
    .WEB        (WEB),  // write:LOW, read:HIGH
    .BWEB       (BWEB),  // bitwise write enable write:LOW
    .D          (D),  // Data into RAM
    .Q          (Q),  // Data out of RAM
    .RTSEL      (),
    .WTSEL      (),
    .SLP        (),
    .DSLP       (),
    .SD         (),
    .PUDELAY    ()
  );





  TS1N16ADFPCLLLVTA128X64M4SWSHOD_tag_array i_tag_array2 (
    .CLK        (),
    .A          (),
    .CEB        (),  // chip enable, active LOW
    .WEB        (),  // write:LOW, read:HIGH
    .BWEB       (),  // bitwise write enable write:LOW
    .D          (),  // Data into RAM
    .Q          (),  // Data out of RAM
    .RTSEL      (),
    .WTSEL      (),
    .SLP        (),
    .DSLP       (),
    .SD         (),
    .PUDELAY    ()
  );

endmodule
