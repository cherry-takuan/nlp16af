// instruction decoder for NLP-16AF

module instruction_decoder(
    input   logic           i_clk,
    input   logic           i_rst_n,
    input   logic   [15:0]  i_ir1,      // instruction reg 1st
    input   logic   [15:0]  i_ir2,      // instruction reg 2nd
    output  logic   [15:0]  o_state,    // instruction reg 3rd
    output  logic           o_err,

    output  logic   [5:0]   o_alu_op,   // alu opcode
    output  logic   [3:0]   o_s1,       // alu source1
    output  logic   [3:0]   o_s2,       // alu source2
    output  logic   [3:0]   o_dest,     // alu destination
    output  logic           o_mem_wr,   // mem write
    output  logic           o_mem_rd    // mem read
);
    // ALU instructions
    parameter ALU_INC = 6'h1B;
    parameter ALU_DEC = 6'h08;
    parameter ALU_MOV = 6'h00;

    // reg address
    parameter IR1   = 4'h1;
    parameter IR2   = 4'h1;
    parameter IR3   = 4'h3;
    parameter FLAG  = 4'h2;
    parameter IP    = 4'hD;
    parameter SP    = 4'hE;
    parameter ZR    = 4'hF;

    // FSM state
    typedef enum logic [3:0] {IF1,D1,IF2,D2,IF3,D3,PUSH1,PUSH2,POP1,POP2,EXE,RD,WR} inst_state_e;
    inst_state_e now_state,next_state;
    logic   [3:0]   inst;
    logic           op_inst,push_inst,pop_inst,call_inst,load_inst,store_inst;
    logic           im16_inst;
    logic   [5:0]   inst_alu_op;
    logic   [3:0]   ra1,ra2,ra3;

    // instruction decode
    assign  inst = i_ir1[15:12];
    assign  im16_inst   = i_ir2[15:12] == 4'h3 || i_ir2[11:8] == 4'h3;
    assign  op_inst     = inst[3:2] == 2'b00;
    assign  push_inst   = inst[3:0] == 4'b1101;
    assign  pop_inst    = inst[3:0] == 4'b1100;
    assign  call_inst   = inst[3:0] == 4'b1011;
    assign  load_inst   = inst[3:0] == 4'b1000;
    assign  store_inst  = inst[3:0] == 4'b1001;

    assign inst_alu_op  = op_inst ? i_ir1[13:8] : {2'b00,i_ir1[11:8]};

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

    always_comb begin
        next_state = now_state;
        o_err = 0;
        o_alu_op = ALU_MOV;
        o_s1 = ZR;
        o_s2 = ZR;
        o_dest = ZR;
        o_mem_rd = 0;
        o_mem_wr = 0;
        case(now_state)
            IF1: begin
                next_state = D1;
                o_alu_op = ALU_MOV;
                o_mem_rd = 1;
                o_dest  = IR1;
            end
            D1: begin
                if(push_inst)       next_state = PUSH1;
                else if(pop_inst)   next_state = POP1;
                else                next_state = IF2;
                o_alu_op = ALU_INC;
                o_s1 = IP;
                o_dest = IP;
            end
            IF2: begin
                next_state = D2;
                o_mem_rd = 1;
                o_dest  = IR2;
            end
            D2: begin
                if(im16_inst)       next_state = IF3;
                else                next_state = EXE;
                o_alu_op = ALU_INC;
                o_s1 = IP;
                o_dest = IP;
            end
            IF3: begin
                next_state = D3;
                o_mem_rd = 1;
                o_dest  = IR3;
            end
            D3: begin
                next_state = EXE;
                o_alu_op = ALU_INC;
                o_s1 = IP;
                o_dest = IP;
            end
            PUSH1: begin
                next_state = PUSH2;
                o_alu_op = ALU_DEC;
                o_s1 = SP;
                o_dest = SP;
            end
            PUSH2: begin
                if(call_inst)       next_state = EXE;
                else                next_state = IF1;
                o_s1 = ra1;
                o_mem_wr = 1;
            end
            POP1: begin
                next_state = POP2;
                o_mem_rd = 1;
                o_dest = ra1;
            end
            POP2: begin
                next_state = IF1;
                o_alu_op = ALU_INC;
                o_s1 = SP;
                o_dest = SP;
            end
            EXE: begin
                if(load_inst)       next_state = RD;
                else if(store_inst) next_state = WR;
                else                next_state = IF1;
                o_alu_op = inst_alu_op;
                o_s1 = ra2;
                o_s2 = ra3;
                o_dest = ra1;
            end
            RD: begin
                next_state = IF1;
                o_mem_rd = 1;
                o_dest = ra1;
            end
            WR: begin
                next_state = IF1;
                o_s1 = ra1;
                o_mem_wr = 1;
            end
            default: begin
                next_state = IF1;
                o_err = 1;
            end
        endcase
    end

endmodule