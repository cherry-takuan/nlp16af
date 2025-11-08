package common_pkg;
    // FSM state type
    typedef enum logic [3:0] {IF1,D1,IF2,D2,IF3,D3,PUSH1,PUSH2,POP1,POP2,EXE,RD,WR} inst_state_e;

    // ALU op type
    typedef enum logic [5:0]{
        ALU_ADD     = 6'h0A,
        ALU_SUB     = 6'h09,
        ALU_INC     = 6'h1B,
        ALU_DEC     = 6'h18,

        ALU_AND     = 6'h06,
        ALU_OR      = 6'h12,
        ALU_NOT     = 6'h14,
        ALU_XOR     = 6'h16,

        ALU_SHL     = 6'h20,
        ALU_SHR     = 6'h30,
        ALU_SAL     = 6'h24,
        ALU_SAR     = 6'h34,
        ALU_ROL     = 6'h22,
        ALU_ROR     = 6'h32,

        ALU_MOV     = 6'h00
    } alu_op_e;

    typedef enum logic [3:0]{
        R_IR1       = 4'h0,
        R_IR2       = 4'h1,
        R_IR3       = 4'h3,

        R_IV        = 4'h2,
        R_FLAG      = 4'h4,
        R_MEM       = 4'hB,
        R_ADDR      = 4'hC,
        R_ZR        = 4'hF,

        R_IP        = 4'hD,
        R_SP        = 4'hE
    } reg_id_e;
endpackage