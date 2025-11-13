module memory_1k(
    input   logic           i_clk,
    input   logic           i_mem_wr,
    input   logic           i_mem_rd,
    input   logic   [15:0]  i_address,
    input   logic   [15:0]  i_data,
    output  logic   [15:0]  o_data,
    
    output  logic           o_finish,
    output  logic   [15:0]  o_result_data
);
    reg   [15:0]  mem[2047:0];
    reg   [15:0]  result_data;
    reg           finish;
    assign o_data = mem[ i_address[9:0] ];
    assign o_result_data = result_data;
    assign o_finish = finish;
    always_ff @(posedge i_clk) begin
        if(i_mem_wr)mem[ i_address[10:0] ] = i_data;

        if (i_address == 16'hFF00) begin
            result_data <= i_data;
            finish <= 1'b1;
        end
    end
    integer i;
    initial begin
        $readmemh("../core_vs_emu/test_mem_dump.txt",mem);
        finish <= 1'b0;
    end
endmodule