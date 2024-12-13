module tag_array_wrapper (
  input CK,
  input CS,
  input OE,
  input WEB,
  input [4:0] A,
  input [21:0] DI,
  output [21:0] DO
);

  TS1N16ADFPCLLLVTA128X64M4SWSHOD_tag_array i_tag_array1 (
    .CLK        (CK),
    .A          (A),
    .CEB        (CS),  // chip enable, active LOW
    .WEB        (WEB),  // write:LOW, read:HIGH
    .BWEB       (`CACHE_WRITE_BITS'hffff),  // bitwise write enable write:LOW
    .D          (DI),  // Data into RAM
    .Q          (DO),  // Data out of RAM
    .RTSEL      (),
    .WTSEL      (),
    .SLP        (),
    .DSLP       (),
    .SD         (),
    .PUDELAY    ()
  );

  TS1N16ADFPCLLLVTA128X64M4SWSHOD_tag_array i_tag_array2 (
    .CLK        (CK),
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
