#include "./obj_dir/Vtest.h" // Verilatedトップモジュール
#include "verilated.h"
#include "verilated_fst_c.h"      // VCD生成用

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    // DUTインスタンス生成
    Vtest* dut = new Vtest();

    // VCDトレース生成
    VerilatedFstC* tfp = new VerilatedFstC;
    Verilated::traceEverOn(true);
    dut->trace(tfp, 100);  // 階層99までトレース
    tfp->open("core.fst");

    // シミュレーションステップ用
    int tickcount = 0;
    auto tick = [&]() {
        // クロック立ち上がりと立ち下がりをシミュレート
        for (int i = 0; i < 2; i++) {
            dut->i_clk = !dut->i_clk;
            dut->eval();
            tfp->dump(tickcount++);
        }
    };

    // クロック初期化
    dut->i_clk = 0;
    dut->i_rst_n = 0;
    tick();          // clk = 1
    dut->i_rst_n = 1;
    for (int i=0; i<40; i++) tick();

    // シミュレーション終了
    tfp->close();
    delete dut;
    delete tfp;
    return 0;
}
