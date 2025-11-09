module memory_1k(
    input   logic           i_clk,
    input   logic           i_mem_wr,
    input   logic           i_mem_rd,
    input   logic   [15:0]  i_address,
    input   logic   [15:0]  i_data,
    output  logic   [15:0]  o_data
);
    reg   [15:0]  mem[1023:0];
    assign o_data = mem[ i_address[9:0] ];
    always_ff @(posedge i_clk) begin
        if(i_mem_wr)mem[ i_address[9:0] ] = i_data;
    end
    integer i;
    initial begin
        $readmemh("../modules/testhex.txt",mem);
    end
endmodule