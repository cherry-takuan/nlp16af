`include "../modules/nlp16af_core.sv"
`include "../modules/common_pkg.sv"
import common_pkg::*;

module nlp_core_tb(
    input   logic           i_clk,
    input   logic           i_rst_n,

    output  logic           o_wr,
    output  logic           o_rd,
    input   logic   [15:0]  i_bus,
    output  logic   [15:0]  o_bus,
    output  logic   [15:0]  o_address
);

    nlp16af DUT(
        .i_clk      (i_clk      ),
        .i_rst_n    (i_rst_n    ),

        .o_wr       (o_wr       ),
        .o_rd       (o_rd       ),
        .i_bus      (i_bus      ),
        .o_bus      (o_bus      ),
        .o_address  (o_address  )
    );
endmodule