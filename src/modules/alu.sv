module ALU (
    input   logic   [5:0]   i_ctrl,
    input   logic   [15:0]  i_data_a,   i_data_b,
    input   logic           i_carry,

    output  logic   [15:0]  o_data,
    output  logic   [3:0]   o_flag
);
    logic   [16:0]  o_alu;
    assign o_alu = alu_core(i_ctrl, i_carry, i_data_a, i_data_b);

    assign flag_s = o_alu[15];
    assign flag_z = o_alu==0;
    assign flag_c = o_alu[16];
    assign flag_v = 1'b0;
    assign o_flag = {flag_c, flag_s, flag_v, flag_z};

    assign  o_data = o_alu[15:0];

    function [16:0] alu_core(
        input   logic   [5:0]   i_ctrl,
        input   logic           i_carry,
        input   logic   [15:0]  i_data_a,
        input   logic   [15:0]  i_data_b
    );
        begin
            case(i_ctrl)
                6'h0A   : alu_core = i_data_a + i_data_b;
                6'h09   : alu_core = i_data_a - i_data_b;
                6'h1B   : alu_core = i_data_a + 16'h0001;
                6'h08   : alu_core = i_data_a - 16'h0001;
                
                6'h06   : alu_core = i_data_a & i_data_b;
                6'h12   : alu_core = i_data_a | i_data_b;
                6'h14   : alu_core = ~i_data_a;
                6'h16   : alu_core = i_data_a ^ i_data_b;

                6'h20   : alu_core = {i_data_a[14:0], 1'b0};         // SHL
                6'h30   : alu_core = {1'b0, i_data_a[15:1]};         // SHR
                6'h24   : alu_core = {i_data_a[14:0], 1'b0};         // SAL
                6'h34   : alu_core = {i_data_a[15], i_data_a[15:1]}; // SAR
                6'h22   : alu_core = {i_data_a[14:0], i_data_a[15]}; // ROL
                6'h32   : alu_core = {i_data_a[0], i_data_a[15:1]};  // ROR

                default : alu_core = i_data_a;
            endcase
        end
    endfunction
endmodule