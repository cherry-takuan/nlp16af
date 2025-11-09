`include "../modules/common_pkg.sv"
import common_pkg::*;

module ALU (
    input   alu_op_e        i_ctrl,
    input   logic   [15:0]  i_data_a,   i_data_b,
    input   logic           i_carry,

    output  logic   [15:0]  o_data,
    output  logic   [3:0]   o_flag
);
    logic   [16:0]  o_alu;
    logic   flag_s,flag_z,flag_c,flag_v;
    assign o_alu = alu_core(i_ctrl, i_carry, i_data_a, i_data_b);

    assign flag_s = o_alu[15];
    assign flag_z = o_alu==0;
    assign flag_c = o_alu[16];
    assign flag_v = 1'b0;
    assign o_flag = {flag_c, flag_s, flag_v, flag_z};

    assign  o_data = o_alu[15:0];

    function [16:0] alu_core(
        input   logic   [5:0]   i_ctrl,
        input   logic           i_carry,
        input   logic   [15:0]  i_data_a,
        input   logic   [15:0]  i_data_b
    );
        begin
            case(i_ctrl)
                ALU_ADD : alu_core = i_data_a + i_data_b;
                ALU_SUB : alu_core = i_data_a - i_data_b;
                ALU_INC : alu_core = i_data_a + 16'h0001;
                ALU_DEC : alu_core = i_data_a - 16'h0001;
                
                ALU_AND : alu_core = {1'b1,i_data_a & i_data_b};
                ALU_OR  : alu_core = {1'b1,i_data_a | i_data_b};
                ALU_NOT : alu_core = {1'b1,~i_data_a          };
                ALU_XOR : alu_core = {1'b1,i_data_a ^ i_data_b};

                ALU_SHL : alu_core = {1'b0,i_data_a[14:0], 1'b0};         // SHL
                ALU_SHR : alu_core = {1'b0,1'b0, i_data_a[15:1]};         // SHR
                ALU_SAL : alu_core = {1'b0,i_data_a[14:0], 1'b0};         // SAL
                ALU_SAR : alu_core = {1'b0,i_data_a[15], i_data_a[15:1]}; // SAR
                ALU_ROL : alu_core = {1'b0,i_data_a[14:0], i_data_a[15]}; // ROL
                ALU_ROR : alu_core = {1'b0,i_data_a[0], i_data_a[15:1]};  // ROR

                default : alu_core = {1'b0,i_data_a};
            endcase
        end
    endfunction
endmodule