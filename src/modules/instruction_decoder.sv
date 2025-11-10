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
    output  reg_id_e        o_s1_addr,  // alu source1
    output  reg_id_e        o_s2_addr,  // alu source2
    output  reg_id_e        o_dest_addr,// alu destination
    output  logic           o_mem_wr,   // mem write
    output  logic           o_mem_rd,   // mem read
    output  reg_id_e        o_addr_reg,
    output  logic           o_reg_w_en,

    input   logic   [3:0]   i_flag_cond,
    output  logic           o_flag_w_en
);
    // FSM state
    inst_state_e now_state,next_state;
    logic   [3:0]   inst;
    logic           op_inst,push_inst,pop_inst,call_inst,load_inst,store_inst,ma_inst;
    logic   [3:0]   flag_fld;
    logic           im16_inst;
    alu_op_e        alu_op;
    reg_id_e        ra1,ra2,ra3;
    flag_type_e     flag_type;
    logic           flag_inv;
    logic           flag_dec;
    logic           reg_w_en,mem_rd,mem_wr;
    logic           wb_phase,wb;

    // instruction decode
    assign  inst        = i_ir1[15:12];
    assign  im16_inst   = i_ir2[15:12] == R_IR3 || i_ir2[11:8] == R_IR3;
    assign  op_inst     = inst[3:2] == 2'b00;
    assign  push_inst   = inst[3:0] == 4'b1101;
    assign  pop_inst    = inst[3:0] == 4'b1100;
    assign  call_inst   = inst[3:0] == 4'b1011;
    assign  load_inst   = inst[3:0] == 4'b1000;
    assign  store_inst  = inst[3:0] == 4'b1001;
    assign  ma_inst     = load_inst | store_inst;
    assign  wb_phase    = now_state == EXE || now_state == EXEA || now_state == WR || now_state == RD || now_state == PUSH1 || now_state == PUSH2 || now_state == POP1 || now_state == POP2;

    assign alu_op       = alu_op_e'(op_inst ? i_ir1[13:8] : {2'b00,i_ir1[11:8]});

    assign ra1          = reg_id_e'(i_ir1[3:0]);
    assign ra2          = reg_id_e'(i_ir2[15:12]);
    assign ra3          = reg_id_e'(i_ir2[11:8]);

    assign  flag_fld    = i_ir1[7:4];
    assign  flag_type   = flag_type_e'(flag_fld[3:1]);
    // flag_fld[0]が1で反転モード
    assign  flag_inv    = flag_fld[0];

    assign  o_state     = now_state;

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
                else if(ma_inst)    next_state = EXEA;
                else                next_state = EXE;
            end
            IF3:                    next_state = D3;
            D3: begin
                if(call_inst)       next_state = PUSH1;
                else if(ma_inst)    next_state = EXEA;
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
                                    next_state = IF1;
            end
            EXEA: begin
                if(load_inst)       next_state = RD;
                else                next_state = WR;
            end
            RD:                     next_state = IF1;
            WR:                     next_state = IF1;
            default: begin
                                    next_state = IF1;
                                    o_err = 1;
            end
        endcase
    end
    
    // controll signal
    always_comb begin
        o_alu_op    = ALU_MOV;
        o_s1_addr   = R_ZR;
        o_s2_addr   = R_ZR;
        o_dest_addr = R_ZR;
        o_addr_reg  = R_ZR;
        mem_rd = 0;
        mem_wr = 0;
        case(now_state)
        //  state            |alu op    |dest   |s1     |s2     |address bus
            IF1     :bus_ctrl(ALU_MOV,  R_IR1,  R_MEM,  R_ZR,   R_IP    );
            D1      :bus_ctrl(ALU_INC,  R_IP,   R_IP,   R_ZR,   R_IP    );
            IF2     :bus_ctrl(ALU_MOV,  R_IR2,  R_MEM,  R_ZR,   R_IP    );
            D2      :bus_ctrl(ALU_INC,  R_IP,   R_IP,   R_ZR,   R_IP    );
            IF3     :bus_ctrl(ALU_MOV,  R_IR3,  R_MEM,  R_ZR,   R_IP    );
            D3      :bus_ctrl(ALU_INC,  R_IP,   R_IP,   R_ZR,   R_IP    );
            PUSH1   :bus_ctrl(ALU_DEC,  R_SP,   R_SP,   R_ZR,   R_SP    );
            PUSH2   :bus_ctrl(ALU_MOV,  R_MEM,  ra1,    R_ZR,   R_SP    );
            POP1    :bus_ctrl(ALU_MOV,  ra1,    R_MEM,  R_ZR,   R_SP    );
            POP2    :bus_ctrl(ALU_INC,  R_SP,   R_SP,   R_ZR,   R_SP    );
            EXE     :bus_ctrl(alu_op,   ra1,    ra2,    ra3,    R_ZR    );
            EXEA    :bus_ctrl(alu_op,   R_ADDR, ra2,    ra3,    R_ZR    );
            RD      :bus_ctrl(ALU_MOV,  ra1,    R_MEM,  R_ZR,   R_ADDR  );
            WR      :bus_ctrl(ALU_MOV,  R_MEM,  ra1,    R_ZR,   R_ADDR  );
            default :bus_ctrl(ALU_MOV,  R_ZR,   R_ZR,   R_ZR,   R_ADDR  );
        endcase
    end
    task automatic bus_ctrl(
        input   alu_op_e    i_alu_op,
        input   reg_id_e    i_dest_addr,
        input   reg_id_e    i_s1_addr,
        input   reg_id_e    i_s2_addr,
        input   reg_id_e    addr_reg
    );
        begin
            o_s1_addr   = i_s1_addr;
            o_s2_addr   = i_s2_addr;
            o_dest_addr = i_dest_addr;
            o_addr_reg  = addr_reg;
            if (i_dest_addr == R_MEM) begin
                mem_wr    = 1;
                mem_rd    = 0;
                //o_dest      = R_ZR;
            end
            else if (i_s1_addr == R_MEM || i_s2_addr == R_MEM) begin
                mem_rd    = 1;
                //o_s1        = R_ZR;
                //o_s2        = R_ZR;
            end
            o_alu_op= i_alu_op;
        end
    endtask
    // 書戻し関連
    // ライトバックのフェーズ(wb_phase)ではフラグに従う
    always_comb begin
        case(flag_type)
            FLAGT_C:    flag_dec  = i_flag_cond[3] ^ flag_inv;
            FLAGT_S:    flag_dec  = i_flag_cond[2] ^ flag_inv;
            FLAGT_V:    flag_dec  = i_flag_cond[1] ^ flag_inv;
            FLAGT_Z:    flag_dec  = i_flag_cond[0] ^ flag_inv;
            FLAGT_NOP:  flag_dec  = 1'b0 ^ flag_inv;
            default:    flag_dec  = 1'b0;
        endcase
    end
    assign  wb = wb_phase ? flag_dec : 1'b1;

    assign  o_reg_w_en  = wb;
    assign  o_mem_wr    = wb & mem_wr;
    assign  o_flag_w_en = wb & (now_state==EXE);
    assign  o_mem_rd    = mem_rd;
endmodule