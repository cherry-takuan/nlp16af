`include "../modules/common_pkg.sv"
import common_pkg::*;

module register_file(
    input   logic           i_clk,
    input   logic           i_rst_n,
    input   logic           i_reg_w_en,

    input   reg_id_e        i_dest_addr,
    input   reg_id_e        i_s1_addr,
    input   reg_id_e        i_s2_addr,
    input   reg_id_e        i_addr_reg,

    input   logic   [15:0]  i_dest_data,
    output  logic   [15:0]  o_s1_data,
    output  logic   [15:0]  o_s2_data,

    output  logic   [15:0]  o_addr,

    output  logic   [15:0]  o_ir1,
    output  logic   [15:0]  o_ir2,

    input   logic   [3:0]   i_flag_alu,
    input   logic           i_flag_w_en,
    output  logic   [3:0]   o_flag_reg
);
    logic   [15:0]  regfile[15:0];
    initial begin
        for (int i = 0; i < 16; i++) begin
            regfile[i] = 16'h0000;
        end
    end
    
    
    assign  o_ir1       = regfile[R_IR1];
    assign  o_ir2       = regfile[R_IR2];

    logic   [15:0]  s1_val,s2_val,addr_val;
    always_comb begin
        s1_val  = reg_read(i_s1_addr );
        s2_val  = reg_read(i_s2_addr );
        addr_val= reg_read(i_addr_reg);
    end
    assign o_s1_data = s1_val;
    assign o_s2_data = s2_val;
    assign o_addr    = addr_val;

    always_ff @( posedge i_clk) begin
        if(!i_rst_n)begin
            regfile[R_IP] <= 16'h0000;
            regfile[R_SP] <= 16'h0000;
        end
        else begin
            // 書込可かつフラグへの書込でなければ通常通り書込(フラグレジスタへの書込は競合すると困るので禁止)
            if(i_reg_w_en && (i_dest_addr != R_FLAG)) regfile[i_dest_addr] <= i_dest_data;
            // それとは関係なくIDの指示でフラグは書き込み
            if(i_flag_w_en) regfile[R_FLAG] <= {12'h000,i_flag_alu};
        end
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