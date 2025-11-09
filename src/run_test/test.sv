`include "../modules/mem.sv"
`include "../modules/nlp16af_core.sv"
`include "../modules/common_pkg.sv"
import common_pkg::*;
module test(
    input   logic   i_clk,
    input   logic   i_rst_n
);
    wire            mem_wr;
    wire            mem_rd;
    wire    [15:0]  i_bus;
    wire    [15:0]  o_bus;
    wire    [15:0]  address;

    nlp16af cpu_core(
        .i_clk      (i_clk      ),
        .i_rst_n    (i_rst_n    ),

        .o_wr       (mem_wr       ),
        .o_rd       (mem_rd       ),
        .i_bus      (i_bus      ),
        .o_bus      (o_bus      ),
        .o_address  (address  )
    );
    memory_1k test_mem(
        .i_clk      (i_clk        ),
        .i_mem_rd   (mem_rd       ),
        .i_mem_wr   (mem_wr       ),

        .i_address  (address    ),
        .i_data     (o_bus      ),
        .o_data     (i_bus      )
    );
endmodule