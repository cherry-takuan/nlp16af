#include "./obj_dir/Vinst_decoder_tb.h" // Verilatedトップモジュール
#include "verilated.h"
#include "verilated_fst_c.h"      // VCD生成用

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    // DUTインスタンス生成
    Vinst_decoder_tb* dut = new Vinst_decoder_tb();

    // VCDトレース生成
    VerilatedFstC* tfp = new VerilatedFstC;
    Verilated::traceEverOn(true);
    dut->trace(tfp, 100);  // 階層99までトレース
    tfp->open("inst_decoder.fst");

    // クロック初期化
    dut->i_clk = 0;
    dut->i_rst_n = 0;
    dut->i_ir1 = 0x2005;
    dut->i_ir2 = 0x6700;

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

    // 初期リセット
    tick();          // clk = 1
    dut->i_rst_n = 1;
    for (int i=0; i<20; i++) tick();

    // 2回目のリセットと異なる入力
    dut->i_rst_n = 0;
    dut->i_ir1 = 0xB01D;
    dut->i_ir2 = 0x3600;
    tick();
    dut->i_rst_n = 1;
    for (int i=0; i<20; i++) tick();

    // シミュレーション終了
    tfp->close();
    delete dut;
    delete tfp;
    return 0;
}
