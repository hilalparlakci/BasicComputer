`timescale 1ns / 1ps
module AddressRegisterFile(I,OutCSel,OutDSel,FunSel,RegSel,OutC,OutD,Clock);
    input wire [15:0] I;
    input wire [1:0] OutCSel;
    input wire [1:0] OutDSel;
    input wire [2:0] FunSel;
    input wire [2:0] RegSel;
    input wire Clock;
    output reg [15:0] OutC;
    output reg [15:0] OutD;
    
    wire E1,E2,E3;
    
    wire [15:0] Q_PC;
    wire [15:0] Q_AR;
    wire [15:0] Q_SP;
                
    assign {E1,E2,E3} = ~RegSel;
    
    Register PC (.Clock(Clock), .I(I), .FunSel(FunSel), .E(E1), .Q(Q_PC));
    Register AR (.Clock(Clock), .I(I), .FunSel(FunSel), .E(E2), .Q(Q_AR));
    Register SP (.Clock(Clock), .I(I), .FunSel(FunSel), .E(E3), .Q(Q_SP));
    
    always @(*) begin
        case (OutCSel)
            2'b00: OutC <= Q_PC;
            2'b01: OutC <= Q_PC;
            2'b10: OutC <= Q_AR;
            2'b11: OutC <= Q_SP;
        endcase
        case (OutDSel)
            2'b00: OutD <= Q_PC;
            2'b01: OutD <= Q_PC;
            2'b10: OutD <= Q_AR;
            2'b11: OutD <= Q_SP;
        endcase
    end
    
endmodule

