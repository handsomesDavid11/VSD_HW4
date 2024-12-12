

module CHIP(
  input            cpu_clk,
  input            axi_clk,
  input            rom_clk,
  input            dram_clk,
  input            cpu_rst,
  input            axi_rst,
  input            rom_rst,
  input            dram_rst,
  input  [   31:0] ROM_out,
  input  [   31:0] DRAM_Q,
  output           ROM_read,
  output           ROM_enable,
  output [   11:0] ROM_address,
  output           DRAM_CSn,
  output [    3:0] DRAM_WEn,
  output           DRAM_RASn,
  output           DRAM_CASn,
  input            DRAM_valid, 
  output [   10:0] DRAM_A,
  output [   31:0] DRAM_D
);

wire           cpu_clk_i;
wire           cpu_rst_i;
wire           axi_clk_i;
wire           axi_rst_i;
wire           rom_clk_i;
wire           rom_rst_i;
wire           dram_clk_i;
wire           dram_rst_i;
wire [   31:0] ROM_out_i;
wire           ROM_read_o;
wire           ROM_enable_o;
wire [   11:0] ROM_address_o;
wire [   31:0] DRAM_Q_i;
wire           DRAM_CSn_o;
wire [    3:0] DRAM_WEn_o;
wire           DRAM_RASn_o;
wire           DRAM_CASn_o;
wire [   10:0] DRAM_A_o;
wire [   31:0] DRAM_D_o;
wire           DRAM_valid_i;


//core instance
top u_TOP(
	.cpu_clk		(cpu_clk_i      ), // CPU CLOCK DOMAIN
	.cpu_rst		(cpu_rst_i      ),
    .axi_clk		(axi_clk_i      ),
    .axi_rst		(axi_rst_i      ),
	.rom_clk        (rom_clk_i      ),//rom
    .rom_rst        (rom_rst_i      ),
    .ROM_out        (ROM_out_i      ),//rom
    .ROM_read       (ROM_read_o     ),
    .ROM_enable     (ROM_enable_o   ),
    .ROM_address    (ROM_address_o  ),
	.dram_clk       (dram_clk_i     ),//DRAM
	.dram_rst       (dram_rst_i     ),
    .DRAM_valid     (DRAM_valid_i   ),
    .DRAM_Q         (DRAM_Q_i       ),
    .DRAM_CSn       (DRAM_CSn_o     ),
    .DRAM_WEn       (DRAM_WEn_o     ),
    .DRAM_RASn      (DRAM_RASn_o    ),
    .DRAM_CASn      (DRAM_CASn_o    ),
    .DRAM_A         (DRAM_A_o       ),
    .DRAM_D         (DRAM_D_o       )
);


//iopad example
//upper
PDCDG_V ipad_DRAM_Q0    (.OEN(1'b1), .IE(1'b1), .I(1'b0), .PAD(DRAM_Q[0 ]), .C(DRAM_Q_i[0 ])); ///DRAM_Q

//left
PDCDG_H opad_DRAM_CSn  (.OEN(1'b0), .IE(1'b0), .I(DRAM_CSn_o     ), .PAD(DRAM_CSn    ), .C());  ///DRAM control

//bottom
PDCDG_V opad_DRAM_D15  (.OEN(1'b0), .IE(1'b0), .I(DRAM_D_o[15 ]  ), .PAD(DRAM_D[15]  ), .C());

///right
PDCDG_H ipad_ROM_out0  (.OEN(1'b1), .IE(1'b1), .I(1'b0), .PAD(ROM_out[0 ]), .C(ROM_out_i[0 ])); ///DRAM_Q


endmodule