`include "../modules/common_pkg.sv"
import common_pkg::*;

module register_file(
    input   logic           i_clk,
    input   logic           i_rst_n,
    input   logic           i_wr_en,

    input   reg_id_e        i_dest_addr,
    input   reg_id_e        i_s1_addr,
    input   reg_id_e        i_s2_addr,
    input   reg_id_e        i_ab_addr,

    input   logic   [15:0]  i_dest_data,
    output  logic   [15:0]  o_s1_data,
    output  logic   [15:0]  o_s2_data,

    output  logic   [15:0]  o_ab_data,

    output  logic   [15:0]  o_ir1,
    output  logic   [15:0]  o_ir2
);
    logic   [15:0]  regfile[15:0];
    initial begin
        for (int i = 0; i < 16; i++) begin
            regfile[i] = 16'h0000;
        end
    end
    
    
    assign  o_ir1       = regfile[R_IR1];
    assign  o_ir2       = regfile[R_IR2];

    logic   [15:0]  s1_val,s2_val,ab_val;
    always_comb begin
        s1_val = reg_read(i_s1_addr);
        s2_val = reg_read(i_s2_addr);
        ab_val = reg_read(i_ab_addr);
    end
    assign o_s1_data = s1_val;
    assign o_s2_data = s2_val;
    assign o_ab_data = ab_val;

    always_ff @( posedge i_clk) begin
        if(!i_rst_n)begin
            regfile[R_IP] <= 16'h0000;
            regfile[R_SP] <= 16'h0000;
        end
        else if(i_wr_en) regfile[i_dest_addr] <= i_dest_data;
    end

    function [15:0]  reg_read(
        input   reg_id_e    i_addr
    );
        begin
            case(i_addr)
                R_IR2:  reg_read = regfile[i_addr] & 16'h00FF;
                R_MEM:  reg_read = 16'h0000;
                R_ZR:   reg_read = 16'h0000;
                default:reg_read = regfile[i_addr];
            endcase
        end
    endfunction
endmodule