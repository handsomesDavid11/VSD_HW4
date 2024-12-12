module data_array_wrapper (
  input CK,
  input CS, 
  input OE,
  input [15:0] WEB,
  input [4:0] A,
  input [127:0] DI,
  output [127:0] DO
);



  TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array1_1 (
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
  
  
    TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array1_2 (
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

  TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array2_1 (
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
  
  TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array2_2 (
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
