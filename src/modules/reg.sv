`include "../modules/common_pkg.sv"
import common_pkg::*;

module register_file(
    input   logic           i_clk,
    input   logic           i_wr_en,

    input   logic   [3:0]   i_dest_addr,
    input   logic   [3:0]   i_s1_addr,
    input   logic   [3:0]   i_s2_addr,
    input   logic   [3:0]   i_ab_addr,

    input   logic   [15:0]  i_dest_data,
    output  logic   [15:0]  o_s1_data,
    output  logic   [15:0]  o_s2_data,

    output  logic   [15:0]  o_ab_data,

    output  logic   [15:0]  o_ir1,
    output  logic   [15:0]  o_ir2
);
    logic   [15:0]  regfile[15:0];
    
    assign  o_s1_data   = reg_read(i_s1_addr);
    assign  o_s2_data   = reg_read(i_s2_addr);
    assign  o_ab_data   = reg_read(i_ab_addr);
    assign  o_ir1       = regfile[R_IR1];
    assign  o_ir2       = regfile[R_IR2];

    always_ff @( posedge i_clk) begin
        if(i_wr_en) regfile[i_dest_addr] <= i_dest_data;
        else        regfile[i_dest_addr] <= regfile[i_dest_addr];
    end

    function logic  [15:0]  reg_read(
        input   logic   [3:0]   i_addr
    );
    case(i_addr)
        R_IR2:  reg_read = regfile[i_addr] & 16'h00FF;
        R_MEM:  reg_read = 16'h0000;
        R_ZR:   reg_read = 16'h0000;
        default:reg_read = regfile[i_addr];
    endcase
    endfunction
endmodule