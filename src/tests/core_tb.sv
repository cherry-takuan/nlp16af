`include "../modules/nlp16af_core.sv"
`include "../modules/common_pkg.sv"
import common_pkg::*;

module nlp_core_tb;
    reg             i_clk=0;
    reg             i_rst_n;

    wire            o_wr;
    wire            o_rd;
    reg     [15:0]  i_bus;
    wire    [15:0]  o_bus;
    wire    [15:0]  o_address;



    initial begin
        $dumpfile("core.vcd");
        $dumpvars(0,DUT);
    end

    nlp16af DUT(
        .i_clk      (i_clk      ),
        .i_rst_n    (i_rst_n    ),

        .o_wr       (o_wr       ),
        .o_rd       (o_rd       ),
        .i_bus      (i_bus      ),
        .o_bus      (o_bus      ),
        .o_address  (o_address  )
    );

    always #1 begin
        i_clk <= ~i_clk;
    end

    initial begin
        i_rst_n     <= 0;
        i_bus       <= 16'h0A05;
        #2
        i_rst_n     <= 1;
        #2
        i_bus       <= 16'h1305;
        #4
        i_bus       <= 16'h000A;
        #20

        $finish;
    end

endmodule