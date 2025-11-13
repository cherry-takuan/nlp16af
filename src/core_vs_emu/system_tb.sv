`include "../core_vs_emu/test_system.sv"
`include "../modules/common_pkg.sv"
import common_pkg::*;
module all_test;
    reg             i_clk=0;
    reg             i_rst_n;

    wire            finish;
    wire    [15:0]  data;

    int clk_count=0;

    initial begin
        $dumpfile("system_tb.vcd");
        $dumpvars(0,DUT);
    end

    test DUT(
        .i_clk  (i_clk  ),
        .i_rst_n(i_rst_n),
        .o_finish(finish),
        .o_result_data(data)
    );

    always #1 begin
        i_clk <= ~i_clk;
        clk_count++;
    end

    initial begin
        integer timeout;
        timeout = 0;
        while (finish == 1'b0 && timeout < 1000) begin
            #1; // 1単位時間待つ
            timeout = timeout + 1;
        end
        if (timeout == 1000)
            $display("Error: reset_nが解除されませんでした");
    end


    initial begin
        i_rst_n     <= 1'b0;
        #2
        i_rst_n     <= 1'b1;
        #2
        wait(finish == 1'b1)
        #2
        $display("result=%04h",data);
        $display("clk=%d",clk_count);
        $finish;
    end

endmodule