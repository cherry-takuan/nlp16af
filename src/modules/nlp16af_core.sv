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
    logic   [15:0]  s1_data,s2_data,dest_data,addr;
    logic   [15:0]  data_a,data_b;
    logic   [15:0]  ir1,ir2;
    logic           carry;
    assign  carry   = flag_reg[3];

    // bus ctrl
    assign  data_a  = s1_addr   == R_MEM ? i_bus    : s1_data;
    assign  data_b  = s2_addr   == R_MEM ? i_bus    : s2_data;
    assign  o_bus   = dest_addr == R_MEM ? dest_data: 16'h0000;
    assign  o_address = addr;

    // io bus
    logic   [15:0]  address;
    logic           mem_wr,mem_rd;

    // ctrl
    alu_op_e        alu_op;
    logic   [3:0]   flag_alu;
    logic   [3:0]   flag_reg;
    logic           flag_w_en;
    logic           reg_w_en;

    inst_state_e    state;
    logic           err;

    instruction_decoder ID(
        .i_clk      (i_clk      ),
        .i_rst_n    (i_rst_n    ),
        .i_ir1      (ir1        ),
        .i_ir2      (ir2        ),

        .o_state    (state      ),
        .o_err      (err        ),
        // alu ctrl
        .o_alu_op   (alu_op     ),
        // reg ctrl
        .o_s1_addr  (s1_addr    ),
        .o_s2_addr  (s2_addr    ),
        .o_dest_addr(dest_addr  ),
        // bus ctrl
        .o_mem_wr   (mem_wr     ),
        .o_mem_rd   (mem_rd     ),
        .o_addr_reg (addr_reg   ),

        .o_reg_w_en (reg_w_en  ),

        .i_flag_cond(flag_reg   ),
        .o_flag_w_en(flag_w_en  )
    );

    ALU ALU(
        .i_ctrl     (alu_op     ),
        .i_data_a   (data_a     ),
        .i_data_b   (data_b     ),
        .i_carry    (carry      ),

        .o_data     (dest_data  ),
        .o_flag     (flag_alu   )
    );
    register_file reg_file(
        // ctrl
        .i_clk      (i_clk      ),
        .i_rst_n    (i_rst_n    ),
        .i_reg_w_en (reg_w_en   ),
        .i_flag_w_en(flag_w_en  ),
        // reg addr sel
        .i_dest_addr(dest_addr  ),
        .i_s1_addr  (s1_addr    ),
        .i_s2_addr  (s2_addr    ),
        .i_addr_reg (addr_reg   ),
        // data bus
        .i_dest_data(dest_data  ),
        .o_s1_data  (s1_data    ),
        .o_s2_data  (s2_data    ),
        .o_addr     (addr       ),
        // ctrl bus
        .o_ir1      (ir1        ),
        .o_ir2      (ir2        ),

        .i_flag_alu (flag_alu   ),
        .o_flag_reg (flag_reg   )
    );
endmodule