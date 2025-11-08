// instruction decoder for NLP-16AF
`include "../modules/common_pkg.sv"
import common_pkg::*;

module instruction_decoder(
    input   logic           i_clk,
    input   logic           i_rst_n,
    input   logic   [15:0]  i_ir1,      // instruction reg 1st
    input   logic   [15:0]  i_ir2,      // instruction reg 2nd
    output  inst_state_e    o_state,    // instruction reg 3rd
    output  logic           o_err,

    output  alu_op_e        o_alu_op,   // alu opcode
    output  reg_id_e        o_s1,       // alu source1
    output  reg_id_e        o_s2,       // alu source2
    output  reg_id_e        o_dest,     // alu destination
    output  logic           o_mem_wr,   // mem write
    output  logic           o_mem_rd    // mem read
);
    // FSM state
    inst_state_e now_state,next_state;
    logic   [3:0]   inst;
    logic           op_inst,push_inst,pop_inst,call_inst,load_inst,store_inst;
    logic           im16_inst;
    alu_op_e        alu_op;
    reg_id_e        ra1,ra2,ra3;

    assign  o_state     = now_state;

    // instruction decode
    assign  inst        = i_ir1[15:12];
    assign  im16_inst   = i_ir2[15:12] == 4'h3 || i_ir2[11:8] == 4'h3;
    assign  op_inst     = inst[3:2] == 2'b00;
    assign  push_inst   = inst[3:0] == 4'b1101;
    assign  pop_inst    = inst[3:0] == 4'b1100;
    assign  call_inst   = inst[3:0] == 4'b1011;
    assign  load_inst   = inst[3:0] == 4'b1000;
    assign  store_inst  = inst[3:0] == 4'b1001;

    assign alu_op       = op_inst ? i_ir1[13:8] : {2'b00,i_ir1[11:8]};

    assign ra1          = i_ir1[3:0];
    assign ra2          = i_ir2[15:12];
    assign ra3          = i_ir2[11:8];

    // update state
    always_ff @( posedge i_clk or negedge i_rst_n ) begin
        if(!i_rst_n)begin
            now_state <= IF1;
        end else begin
            now_state <= next_state;
        end
    end
    // state transration
    always_comb begin
        next_state = now_state;
        o_err = 0;
        case(now_state)
            IF1:                    next_state = D1;
            D1: begin
                if(push_inst)       next_state = PUSH1;
                else if(pop_inst)   next_state = POP1;
                else                next_state = IF2;
            end
            IF2:                    next_state = D2;
            D2: begin
                if(im16_inst)       next_state = IF3;
                else if(call_inst)  next_state = PUSH1;
                else                next_state = EXE;
            end
            IF3:                    next_state = D3;
            D3: begin
                if(call_inst)       next_state = PUSH1;
                else                next_state = EXE;
            end
            PUSH1:                  next_state = PUSH2;
            PUSH2: begin
                if(call_inst)       next_state = EXE;
                else                next_state = IF1;
            end
            POP1:                   next_state = POP2;
            POP2:                   next_state = IF1;
            EXE: begin
                if(load_inst)       next_state = RD;
                else if(store_inst) next_state = WR;
                else                next_state = IF1;
            end
            RD:                     next_state = IF1;
            WR:                     next_state = IF1;
            default: begin
                                    next_state = IF1;
                                    o_err = 1;
            end
        endcase
    end
    
    // countroll signal
    always_comb begin
        o_alu_op = ALU_MOV;
        o_s1 = R_ZR;
        o_s2 = R_ZR;
        o_dest = R_ZR;
        o_mem_rd = 0;
        o_mem_wr = 0;
        case(now_state)
            IF1     :bus_ctrl(ALU_MOV,  R_IR1,      R_MEM,      R_ZR);
            D1      :bus_ctrl(ALU_INC,  R_IP,       R_IP,       R_ZR);
            IF2     :bus_ctrl(ALU_MOV,  R_IR2,      R_MEM,      R_ZR);
            D2      :bus_ctrl(ALU_INC,  R_IP,       R_IP,       R_ZR);
            IF3     :bus_ctrl(ALU_MOV,  R_IR3,      R_MEM,      R_ZR);
            D3      :bus_ctrl(ALU_INC,  R_IP,       R_IP,       R_ZR);
            PUSH1   :bus_ctrl(ALU_DEC,  R_SP,       R_SP,       R_ZR);
            PUSH2   :bus_ctrl(ALU_MOV,  R_MEM,      ra1,        R_ZR);
            POP1    :bus_ctrl(ALU_MOV,  ra1,        R_MEM,      R_ZR);
            POP2    :bus_ctrl(ALU_INC,  R_SP,       R_SP,       R_ZR);
            EXE     :bus_ctrl(alu_op,   ra1,        ra2,         ra3);
            RD      :bus_ctrl(ALU_MOV,  ra1,        R_MEM,      R_ZR);
            WR      :bus_ctrl(ALU_MOV,  R_MEM,      ra1,        R_ZR);
            default :bus_ctrl(ALU_MOV,  R_ZR,       R_ZR,       R_ZR);
        endcase
    end

    task automatic bus_ctrl(
        input   logic   [5:0]   i_alu_op,
        input   logic   [3:0]   i_dest,
        input   logic   [3:0]   i_s1,
        input   logic   [3:0]   i_s2
    );
        begin
            o_s1    = i_s1;
            o_s2    = i_s2;
            o_dest  = i_dest;
            if (i_dest == R_MEM) begin
                o_mem_wr    = 1;
                o_mem_rd    = 0;
                o_dest      = R_ZR;
            end
            else if (i_s1 == R_MEM || i_s2 == R_MEM) begin
                o_mem_rd    = 1;
                o_s1        = R_ZR;
                o_s2        = R_ZR;
            end
            o_alu_op= i_alu_op;
        end
    endtask
endmodule