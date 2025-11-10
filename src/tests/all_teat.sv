`include "../tests/test.sv"
`include "../modules/common_pkg.sv"
import common_pkg::*;
module all_test;
    reg             i_clk=0;
    reg             i_rst_n;

    initial begin
        $dumpfile("all_test.vcd");
        $dumpvars(0,DUT);
    end

    test DUT(
        .i_clk  (i_clk  ),
        .i_rst_n(i_rst_n)
    );

    always #1 begin
        i_clk <= ~i_clk;
    end

    initial begin
        i_rst_n     <= 1'b0;
        #2
        i_rst_n     <= 1'b1;
        #80

        $finish;
    end

endmodule