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
        // 1. リセット処理
        i_rst_n     <= 1'b0;
        #2
        $display("CPU start up");
        i_rst_n     <= 1'b1;
        #2

        // 2. 正常終了とタイムアウトの並列監視
        fork
            // 処理A: 正常終了を待つ
            begin
                wait(finish === 1'b1);
            end
            // 処理B: タイムアウト時間を待つ
            begin
                #100000; // 任意のタイムアウト時間
                $display("Error: time out");
            end
        join_any // どちらか一方が成立したら次へ進む

        // 3. 結果の出力と終了処理
        if (finish !== 1'b1) begin
            $display("Simulation failed due to timeout.");
            $finish;
        end

        $display("result=%04h", data);
        $display("clk=%d", clk_count);
        $finish;
    end

endmodule