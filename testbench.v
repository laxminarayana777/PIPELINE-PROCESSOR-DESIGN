module testbench;

reg clk;
reg rst;
reg [31:0] instr;
wire [31:0] result;

pipeline DUT (
    .clk(clk),
    .rst(rst),
    .instr(instr),
    .result(result)
);

initial begin
    clk = 0;
    rst = 1;
    instr = 0;
    #100 rst = 0; // Increased reset timing
end

always #5 clk = ~clk;

initial begin
    // Initialize register file
    DUT.reg_file[0] = 10;
    DUT.reg_file[1] = 20;
    DUT.reg_file[2] = 30;
    
    // Test ADD instruction
    #20 instr = 32'b00000011111001101100000000010010; // ADD $t0, $zero, 10
    #10 instr = 32'b00000011111001101100000000110010; // ADD $t1, $t0, 10
    #10 instr = 32'b00000011111001101100000001010010; // ADD $t2, $t1, 10

    
    // Test SUB instruction
    #10 instr = 32'b00000000000000000000000001110010; // SUB $t3, $t2, 5

    
    // Test AND instruction
    #10 instr = 32'b00000000000000000000000010110010; // AND $t4, $t3, 15
    
    // Test LOAD instruction
    #10 instr = 32'b00000000000000000000000100010010; // LOAD $t5, 0($t4)
    
    #100 $finish;
end

endmodule
