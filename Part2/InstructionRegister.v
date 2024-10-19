`timescale 1ns / 1ps

module InstructionRegister(
    input wire Clock,        
    input wire LH, 
    input wire Write,        
    input wire [7:0] I,   
    output reg [15:0] IROut  
);

    always @(posedge Clock) begin
        if(Write == 1'b0) begin 
            IROut <= IROut; 
        end
        else begin
            if (LH) begin
                IROut[15:8] <= I;
            end
            else begin 
                IROut[7:0] <= I;
            end
        end
    end

endmodule




