`include "../modules/instruction_decoder.sv"
module inst_decoder_tb(
    input   logic           i_clk,
    input   logic           i_rst_n,
    input   logic   [15:0]  i_ir1,      // instruction reg 1st
    input   logic   [15:0]  i_ir2,      // instruction reg 2nd
    output  inst_state_e    o_state,    // instruction reg 3rd
    output  logic           o_err,

    output  alu_op_e        o_alu_op,   // alu opcode
    output  reg_id_e        o_s1,       // alu source1
    output  reg_id_e        o_s2,       // alu source2
    output  reg_id_e        o_dest,     // alu destination
    output  logic           o_mem_wr,   // mem write
    output  logic           o_mem_rd    // mem read
);
    instruction_decoder instruction_decoder(
        .i_clk      (i_clk        ),
        .i_rst_n    (i_rst_n      ),
        .i_ir1      (i_ir1        ),
        .i_ir2      (i_ir2        ),

        .o_state    (o_state      ),
        .o_err      (o_err        ),

        .o_alu_op   (o_alu_op     ),
        .o_s1       (o_s1         ),
        .o_s2       (o_s2         ),
        .o_dest     (o_dest       ),
        .o_mem_wr   (o_mem_wr     ),
        .o_mem_rd   (o_mem_rd     )
    );
endmodule