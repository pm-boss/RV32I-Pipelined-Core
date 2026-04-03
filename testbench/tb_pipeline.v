`timescale 1ns / 1ps
module tb_pipeline;
reg clk;
reg reset;
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
initial begin
    reset = 0;
    #100;
    reset = 1;
end
wire [31:0] inst_mem_read_data;
wire        inst_mem_is_valid;
wire [31:0] dmem_read_data;
wire        dmem_write_valid;
wire        dmem_read_valid;
wire        exception;
wire [31:0] inst_mem_address;
wire        dmem_read_ready;
wire [31:0] dmem_read_address;
wire        dmem_write_ready;
wire [31:0] dmem_write_address;
wire [31:0] dmem_write_data;
wire [3:0]  dmem_write_byte;
wire [31:0] pc_out;
assign inst_mem_is_valid = 1'b1;
assign dmem_write_valid  = 1'b1;
assign dmem_read_valid   = 1'b1;

pipe DUT (
    .clk                (clk),
    .reset              (reset),
    .stall              (1'b0),
    .exception          (exception),
    .pc_out             (pc_out),
    .inst_mem_is_valid  (inst_mem_is_valid),
    .inst_mem_read_data (inst_mem_read_data),
    .dmem_read_data_temp(dmem_read_data),
    .dmem_write_valid   (dmem_write_valid),
    .dmem_read_valid    (dmem_read_valid),
    .inst_mem_address   (inst_mem_address),
    .dmem_read_ready    (dmem_read_ready),
    .dmem_read_address  (dmem_read_address),
    .dmem_write_ready   (dmem_write_ready),
    .dmem_write_address (dmem_write_address),
    .dmem_write_data    (dmem_write_data),
    .dmem_write_byte    (dmem_write_byte)
);
instr_mem IMEM (
    .clk  (clk),
    .pc   (inst_mem_address),
    .instr(inst_mem_read_data)
);
data_mem DMEM (
    .clk  (clk),
    .re   (dmem_read_ready),
    .raddr(dmem_read_address),
    .rdata(dmem_read_data),
    .we   (dmem_write_ready),
    .waddr(dmem_write_address),
    .wdata(dmem_write_data),
    .wstrb(dmem_write_byte)
);
initial begin
    $dumpfile("pipeline.vcd");
    $dumpvars(0, tb_pipeline);
end
initial begin
    #20000;
    $finish;
end
// --- ADD THIS BLOCK FOR TERMINAL OUTPUT ---

// Declare the register to hold the previous value
reg [31:0] prev_result;

always @(posedge clk) begin
    // Make sure we don't print garbage values during the initial reset phase
    if (reset == 1'b1) begin 
        
        // 1. Print time and result ONLY when register 10 (a0) actually changes
        if (DUT.regs[15] !== prev_result) begin
            $display("time: %18t, result = %10d", $time, DUT.regs[15]);
            prev_result = DUT.regs[15];
        end
        
        // 2. Always print the PC every single cycle
        $display("next_pc = %08h", DUT.pc); 

        // 3. Stop simulation when the 'ret' instruction (0x00008067) is reached
        if (DUT.instruction == 32'h00008067) begin
            
            // Wait a tiny bit to ensure the final Write Back finishes
            #10; 
            
            $display("--- Execution Finished Successfully ---");
            $finish;
            // Wait a tiny bit to ensure the final Write Back finishes
             
            
            
        end
    end
end
endmodule