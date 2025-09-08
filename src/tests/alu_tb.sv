`include "../modules/alu.sv"
module alu_tb;
    reg     [15:0]  data_a;
    reg     [15:0]  data_b;
    reg     [5:0]   ctrl;
    reg             carry;

    wire    [15:0]  result;
    wire    [3:0]   flag;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0,DUT);
    end

    ALU DUT(
        .i_ctrl     (ctrl       ),
        .i_data_a   (data_a     ),
        .i_data_b   (data_b     ),
        .i_carry    (carry      ),

        .o_data     (result     ),
        .o_flag     (flag       )
    );

    initial begin
        data_a      <=  16'h0001;
        data_b      <=  16'h0002;
        ctrl        <=  6'h0A;
        carry       <=  0;
        #1
        data_a      <=  16'h0002;
        data_b      <=  16'h0002;
        ctrl        <=  6'h0A;
        #1

        data_a      <=  16'h0001;
        data_b      <=  16'h0002;
        ctrl        <=  6'h09;
        #1

        data_a      <=  16'h0002;
        data_b      <=  16'h0002;
        ctrl        <=  6'h09;
        #1


        data_a      <=  16'h0001;
        data_b      <=  16'h0002;
        ctrl        <=  6'h06;
        carry       <=  0;
        #1
        data_a      <=  16'h0002;
        data_b      <=  16'h0002;
        ctrl        <=  6'h06;
        #1

        data_a      <=  16'h0001;
        data_b      <=  16'h0002;
        ctrl        <=  6'h12;
        #1

        data_a      <=  16'h0002;
        data_b      <=  16'h0002;
        ctrl        <=  6'h12;
        #1

        $finish;
    end
endmodule