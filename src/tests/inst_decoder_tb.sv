`include "../modules/instruction_decoder.sv"
module inst_decoder_tb;
    reg             clk=0;
    reg             rst_n;
    reg     [15:0]  ir1;
    reg     [15:0]  ir2;

    wire    [15:0]  state;
    wire            err;

    initial begin
        $dumpfile("inst_decoder.vcd");
        $dumpvars(0,DUT);
    end

    instruction_decoder DUT(
        .i_clk      (clk        ),
        .i_rst_n    (rst_n      ),
        .i_ir1      (ir1        ),
        .i_ir2      (ir2        ),

        .o_state    (state      ),
        .o_err      (err        )
    );

    always #1 begin
        clk <= ~clk;
    end

    initial begin
        rst_n       <=  0;
        ir1         <=  16'h0000;
        ir2         <=  16'h3000;
        #2
        rst_n       <=  1;
        #40

        $finish;
    end
endmodule