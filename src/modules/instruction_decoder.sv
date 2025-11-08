// instruction decoder for NLP-16AF

module instruction_decoder(
    input   logic           i_clk,
    input   logic           i_rst_n,
    input   logic   [15:0]  i_ir1,
    input   logic   [15:0]  i_ir2,

    output  logic           o_err,

    output  logic   [3:0]   o_s1,
    output  logic   [3:0]   o_s2,
    output  logic   [3:0]   o_dest,

    output  logic           o_ip_inc

);
    typedef enum logic [3:0] {IF1,IF1D,IF2,IF2D,IF3,PUSH1,PUSH2,POP1,POP2,EXE,RD,WR} inst_state_e;
    inst_state_e now_state,next_state;
    logic   [3:0]   inst;
    logic           op_inst,push_inst,pop_inst,call_inst,load_inst,store_inst;
    logic           im16_inst;
    logic   [15:0]  ir1_reg,ir2_reg;
    logic   [3:0]   s1,s2,dest;
    logic           ip_inc;
    assign  inst = ir1_reg;
    assign  im16_inst   = ir2_reg[15:12] == 4'h3 || ir2_reg[11:8] == 4'h3;
    assign  op_inst     = inst[3:2] == 2'b00;
    assign  push_inst   = inst[3:0] == 4'b1101;
    assign  pop_inst    = inst[3:0] == 4'b1100;
    assign  call_inst   = inst[3:0] == 4'b1011;
    assign  load_inst   = inst[3:0] == 4'b1000;
    assign  store_inst  = inst[3:0] == 4'b1001;

    always_ff @( posedge i_clk or negedge i_rst_n ) begin
        if(!i_rst_n)begin
            now_state <= IF1;
        end else begin
            now_state <= next_state;
        end
    end

    always_ff @( posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            ir1_reg <= 16'h0000;
            ir2_reg <= 16'h0000;
        end else if(now_state == IF1) begin
            ir1_reg <= i_ir1;
        end else if(now_state == IF2) begin
            ir2_reg <= i_ir2;
        end
        o_s1 <= s1;
        o_s2 <= s2;
        o_dest <= dest;
        o_ip_inc <= ip_inc;
    end

    always_comb begin
        next_state = now_state;
        o_err = 0;
        case(now_state)
            IF1:  begin
                next_state = IF1D;
            end
            IF1D: begin
                if(push_inst)       next_state = PUSH1;
                else if(pop_inst)   next_state = POP1;
                else                next_state = IF2;
            end
            IF2: begin
                next_state = IF2D;
            end
            IF2D: begin
                if(im16_inst)       next_state = IF3;
                else                next_state = EXE;
            end
            IF3: begin
                next_state = EXE;
            end
            PUSH1: begin
                next_state = PUSH2;
            end
            PUSH2: begin
                if(call_inst)       next_state = EXE;
                else                next_state = IF1;
            end
            POP1: begin
                next_state = POP2;
            end
            POP2: begin
                next_state = IF1;
            end
            EXE: begin
                if(load_inst)       next_state = RD;
                else if(store_inst) next_state = WR;
                else                next_state = IF1;
            end
            RD: begin
                next_state = IF1;
            end
            WR: begin
                next_state = IF1;
            end
            default:
                next_state = IF1;
        endcase
    end

endmodule