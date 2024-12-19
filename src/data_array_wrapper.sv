module data_array_wrapper (
  input CK,
  input CS, 
  input OE,
  input [15:0] WEB,
  input [4:0] A,
  input [127:0] DI,
  output [127:0] DO
);

  logic En;
  logic [127:0] BWEB;

  always_comb begin
    case(WEB)
      16'hfff0:
        BWEB = {{96{1'b1}},{32{1'b0}}};
      16'hff0f:
        BWEB = {{64{1'b1}},{32{1'b0}},{32{1'b1}}};
      16'hf0ff:
        BWEB = {{32{1'b1}},{32{1'b0}},{64{1'b1}}};
      16'h0fff:
        BWEB = {{32{1'b0}},{96{1'b1}}};
      default:
        BWEB = {128{1'b1}};
    endcase
    

  end
  assign En = &WEB;

  TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array1_1 (
    .CLK        (CK),
    .A          (A),
    .CEB        (1'b0),  // chip enable, active LOW
    .WEB        (En),  // write:LOW, read:HIGH
    .BWEB       (BWEB[127:64]),  // bitwise write enable write:LOW
    .D          (DI[127:64]),  // Data into RAM
    .Q          (DO[127:64]),  // Data out of RAM
    .RTSEL      (),
    .WTSEL      (),
    .SLP        (),
    .DSLP       (),
    .SD         (),
    .PUDELAY    ()
  );
  
  
    TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array1_2 (
    .CLK        (CK),
    .A          (A),
    .CEB        (1'b0),  // chip enable, active LOW
    .WEB        (En),  // write:LOW, read:HIGH
    .BWEB       (BWEB[63:0]),  // bitwise write enable write:LOW
    .D          (DI[63:0]),  // Data into RAM
    .Q          (DO[63:0]),  // Data out of RAM
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
