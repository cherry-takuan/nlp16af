`include "../modules/common_pkg.sv"
`include "../modules/instruction_decoder.sv"
`include "../modules/alu.sv"
`include "../modules/reg.sv"

import common_pkg::*;
module nlp16af(
    input   logic           i_clk,
    input   logic           i_rst_n,

    output  logic           o_wr,
    output  logic           o_rd,
    input   logic   [15:0]  i_bus,
    output  logic   [15:0]  o_bus,
    output  logic   [15:0]  o_address
);
    // internal bus
    reg_id_e        s1_addr,s2_addr,dest_addr,addr_reg;
    logic   [15:0]  s1_data,s2_data,dest_data,addr_data;
    logic   [15:0]  data_a,data_b;

    // bus ctrl
    assign  data_a  = s1_addr   == R_MEM ? i_bus    : s1_data;
    assign  data_b  = s2_addr   == R_MEM ? i_bus    : s2_data;
    assign  o_bus   = dest_addr == R_MEM ? dest_data: 16'h0000;

    logic   [15:0]  ir1,ir2;

    // io bus
    logic   [15:0]  address;
    logic           mem_wr,mem_rd;

    // ctrl
    alu_op_e        alu_op;
    logic   [3:0]   flag;
    inst_state_e    state;
    logic           err;

    instruction_decoder ID(
        .i_clk      (i_clk      ),
        .i_rst_n    (i_rst_n    ),
        .i_ir1      (ir1        ),
        .i_ir2      (ir2        ),

        .o_state    (state      ),
        .o_err      (err        ),

        .o_alu_op   (alu_op     ),
        .o_s1       (s1_addr    ),
        .o_s2       (s2_addr    ),
        .o_dest     (dest_addr  ),
        .o_mem_wr   (mem_wr     ),
        .o_mem_rd   (mem_rd     ),

        .o_addr_reg (addr_reg   )
    );

    ALU ALU(
        .i_ctrl     (alu_op     ),
        .i_data_a   (data_a     ),
        .i_data_b   (data_b     ),
        .i_carry    (1'b0       ),

        .o_data     (dest_data  ),
        .o_flag     (flag       )
    );
    register_file reg_file(
        .i_clk      (i_clk      ),
        .i_rst_n    (i_rst_n    ),
        .i_wr_en    (1'b1       ),

        .i_dest_addr(dest_addr  ),
        .i_s1_addr  (s1_addr    ),
        .i_s2_addr  (s2_addr    ),
        .i_ab_addr  (addr_reg   ),

        .i_dest_data(dest_data  ),
        .o_s1_data  (s1_data    ),
        .o_s2_data  (s2_data    ),
        .o_ab_data  (addr_data  ),

        .o_ir1      (ir1        ),
        .o_ir2      (ir2        )
    );
endmodule