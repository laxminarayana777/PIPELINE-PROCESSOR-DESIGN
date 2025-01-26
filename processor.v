module pipeline(
    input  wire clk,
    input  wire rst,
    input  wire [31:0] instr,
    output wire [31:0] result
);

// Register file
reg [31:0] reg_file [0:31];

// Memory
reg [31:0] mem [0:255];

// Pipeline registers
reg [31:0] if_id_instr;
reg [31:0] if_id_pc;
reg [31:0] id_ex_instr;
reg [31:0] id_ex_op1;
reg [31:0] id_ex_op2;
reg [4:0] id_ex_rd;
reg [31:0] ex_ma_instr;
reg [31:0] ex_ma_op1;
reg [31:0] ex_ma_op2;
reg [4:0] ex_ma_rd;
reg [31:0] ma_wb_instr;
reg [31:0] ma_wb_result;
reg [4:0] ma_wb_rd;

// Instruction fetch stage
always @(posedge clk) begin
    if (rst) begin
        if_id_instr <= 0;
        if_id_pc <= 0;
    end else begin
        if_id_instr <= instr;
        if_id_pc <= if_id_pc + 4;
    end
end

// Instruction decode stage
always @(posedge clk) begin
    if (rst) begin
        id_ex_instr <= 0;
        id_ex_op1 <= 0;
        id_ex_op2 <= 0;
        id_ex_rd <= 0;
    end else begin
        id_ex_instr <= if_id_instr;
        id_ex_op1 <= reg_file[if_id_instr[15:11]];
        id_ex_op2 <= reg_file[if_id_instr[20:16]];
        id_ex_rd <= if_id_instr[15:11];
    end
end

// Execution stage
always @(posedge clk) begin
    if (rst) begin
        ex_ma_instr <= 0;
        ex_ma_op1 <= 0;
        ex_ma_op2 <= 0;
        ex_ma_rd <= 0;
    end else begin
        ex_ma_instr <= id_ex_instr;
        ex_ma_op1 <= id_ex_op1;
        ex_ma_op2 <= id_ex_op2;
        ex_ma_rd <= id_ex_rd;
        
        case (id_ex_instr[6:0])
            6'b000000: ex_ma_op1 <= ex_ma_op1 + ex_ma_op2; // ADD
            6'b000001: ex_ma_op1 <= ex_ma_op1 - ex_ma_op2; // SUB
            6'b000010: ex_ma_op1 <= ex_ma_op1 & ex_ma_op2; // AND
            default: ex_ma_op1 <= 0;
        endcase
    end
end

// Memory access/write back stage
always @(posedge clk) begin
    if (rst) begin
        ma_wb_instr <= 0;
        ma_wb_result <= 0;
        ma_wb_rd <= 0;
    end else begin
        ma_wb_instr <= ex_ma_instr;
        ma_wb_result <= ex_ma_op1;
        ma_wb_rd <= ex_ma_rd;
        
        case (ex_ma_instr[6:0])
            6'b000100: ma_wb_result <= mem[ex_ma_op1]; // LOAD
            default: ma_wb_result <= ex_ma_op1;
        endcase
        
        // Write back to register file
        if (~rst) begin
            reg_file[ma_wb_rd] <= ma_wb_result;
        end
    end
end


assign result = ma_wb_result;

endmodule
