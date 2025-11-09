`include "../modules/reg.sv"
`include "../modules/common_pkg.sv"
import common_pkg::*;
module regfile_tb;
    reg             clk=0;
    reg             wr_en;
    reg_id_e        dest_addr;
    reg_id_e        s1_addr;
    reg_id_e        s2_addr;
    reg_id_e        ab_addr;

    reg     [15:0]  data;

    wire    [15:0]  s1_data;
    wire    [15:0]  s2_data;
    wire    [15:0]  ab_data;

    wire    [15:0]  ir1;
    wire    [15:0]  ir2;

    initial begin
        $dumpfile("reg_tb.vcd");
        $dumpvars(0,DUT);
    end

    register_file DUT(
        .i_clk      (clk        ),
        .i_wr_en    (wr_en      ),

        .i_dest_addr (dest_addr  ),
        .i_s1_addr   (s1_addr    ),
        .i_s2_addr   (s2_addr    ),
        .i_ab_addr   (ab_addr    ),

        .i_dest_data (data       ),
        .o_s1_data   (s1_data    ),
        .o_s2_data   (s2_data    ),
        .o_ab_data   (ab_data    ),

        .o_ir1       (ir1        ),
        .o_ir2       (ir2        )
    );

    always #1 begin
        clk <= ~clk;
    end
    initial begin
        wr_en       <= 1;
        s1_addr     <= R_IR1;
        s2_addr     <= R_IR2;
        dest_addr   <= R_IR1;
        ab_addr     <= R_IP;
        data        <= 16'hB01D;
        #2
        dest_addr   <= R_IR2;
        data        <= 16'h1510;
        #2
        dest_addr   <= R_ZR;
        data        <= 16'hFFFF;
        s1_addr     <= R_ZR;
        #2


        wr_en       <= 0;
        #2
        dest_addr   <= R_IR1;
        data        <= 16'h0000;
        #2
        dest_addr   <= R_IR2;
        data        <= 16'h0000;
        #2
        dest_addr   <= R_ZR;
        data        <= 16'hFFFF;
        s1_addr     <= R_ZR;
        #2

        wr_en       <= 1;
        s1_addr     <= R_IP;
        dest_addr   <= R_IP;
        data        <= 0;
        #2
        data        <= s1_data+1;
        #2
        data        <= s1_data+1;
        #2

        $finish;
    end
endmodule