`timescale 1ns / 1ps
module RegisterFile(I,OutASel,OutBSel,FunSel,RegSel,ScrSel,OutA,OutB, Clock);
    input wire [15:0] I;
    input wire [2:0] OutASel;
    input wire [2:0] OutBSel;
    input wire [2:0] FunSel;
    input wire [3:0] RegSel;
    input wire [3:0] ScrSel;
    input wire Clock;
    output reg [15:0] OutA;
    output reg [15:0] OutB;
    
    wire ER1,ER2,ER3,ER4;
    wire ES1,ES2,ES3,ES4;
    
    wire [15:0] Q_R1;
    wire [15:0] Q_R2;
    wire [15:0] Q_R3;
    wire [15:0] Q_R4;
    wire [15:0] Q_S1;
    wire [15:0] Q_S2;
    wire [15:0] Q_S3;
    wire [15:0] Q_S4;
        
    assign {ER1,ER2,ER3,ER4} = ~RegSel;
    assign {ES1,ES2,ES3,ES4} = ~ScrSel;
    
    Register R1 (.Clock(Clock),.FunSel(FunSel),.I(I),.E(ER1),.Q(Q_R1));
    Register R2 (.Clock(Clock),.FunSel(FunSel),.I(I),.E(ER2),.Q(Q_R2));
    Register R3 (.Clock(Clock),.FunSel(FunSel),.I(I),.E(ER3),.Q(Q_R3));
    Register R4 (.Clock(Clock),.FunSel(FunSel),.I(I),.E(ER4),.Q(Q_R4));

    Register S1 (.Clock(Clock),.FunSel(FunSel),.I(I),.E(ES1),.Q(Q_S1));
    Register S2 (.Clock(Clock),.FunSel(FunSel),.I(I),.E(ES2),.Q(Q_S2));
    Register S3 (.Clock(Clock),.FunSel(FunSel),.I(I),.E(ES3),.Q(Q_S3));
    Register S4 (.Clock(Clock),.FunSel(FunSel),.I(I),.E(ES4),.Q(Q_S4));
    
    always @(*) begin
        case (OutASel)
            3'b000: OutA <= Q_R1;
            3'b001: OutA  <= Q_R2;
            3'b010: OutA  <= Q_R3;
            3'b011: OutA  <= Q_R4;
            3'b100: OutA  <= Q_S1;
            3'b101: OutA  <= Q_S2;
            3'b110: OutA  <= Q_S3;
            3'b111: OutA  <= Q_S4;
        endcase
        case (OutBSel)
            3'b000: OutB <= Q_R1;
            3'b001: OutB <= Q_R2;
            3'b010: OutB <= Q_R3;
            3'b011: OutB <= Q_R4;
            3'b100: OutB <= Q_S1;
            3'b101: OutB <= Q_S2;
            3'b110: OutB <= Q_S3;
            3'b111: OutB <= Q_S4;
        endcase
    end   
endmodule