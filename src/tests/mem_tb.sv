`include "../modules/mem.sv"
`include "../modules/common_pkg.sv"
import common_pkg::*;
module regfile_tb;
    reg             clk=0;
    reg             mem_wr;
    reg             mem_rd;
    reg     [15:0]  address;
    reg     [15:0]  write_data;
    wire    [15:0]  read_data;

    initial begin
        $dumpfile("mem_tb.vcd");
        $dumpvars(0,DUT);
    end

    memory_1k DUT(
        .i_clk      (clk        ),
        .i_mem_rd   (mem_rd     ),
        .i_mem_wr   (mem_wr     ),

        .i_address  (address    ),
        .i_data     (write_data ),
        .o_data     (read_data  )
    );

    always #1 begin
        clk <= ~clk;
    end
    initial begin
        mem_wr <= 1'b0;
        mem_rd <= 1'b0;
        write_data <= 16'h0000;

        address <= 16'h0000;
        #2
        address <= 16'h0001;
        #2
        address <= 16'h0002;
        #2
        address <= 16'h0003;
        #2

        mem_wr <= 1'b1;
        address <= 16'h0000;
        write_data <= 16'h1000;
        #2
        address <= 16'h0001;
        write_data <= 16'h2000;
        #2
        address <= 16'h0002;
        write_data <= 16'h3000;
        #2

        mem_wr <= 1'b0;
        mem_rd <= 1'b0;
        write_data <= 16'h0000;

        address <= 16'h0000;
        #2
        address <= 16'h0001;
        #2
        address <= 16'h0002;
        #2
        address <= 16'h0003;
        #2

        $finish;
    end
endmodule