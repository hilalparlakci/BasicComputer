`timescale 1ns / 1ps



module MUX_2TO1(S, D0, D1, Y);
    input wire S;
    input wire [7:0] D0;
    input wire [7:0] D1;
    output reg [7:0] Y;

    always@(*) begin
        case(S)
            1'b0: Y <= D0;
            1'b1: Y <= D1;
            default: Y <= D0;
        endcase
    end
endmodule

module MUX_4TO1(S, D0, D1, D2, D3, Y);
    input wire [1:0] S;
    input wire [15:0] D0; 
    input wire [15:0] D1;
    input wire [15:0] D2;
    input wire [15:0] D3;
    output reg [15:0] Y;

    always@(*) begin
        case(S)
            2'b00: Y <= D0;
            2'b01: Y <= D1;
            2'b10: Y <= D2;
            2'b11: Y <= D3;
            default: Y <= D0;
        endcase
    end
endmodule

module ALUSystem(
RF_OutASel,   
RF_OutBSel, 
RF_FunSel,  
RF_RegSel,
RF_ScrSel,     
ALU_FunSel,
ALU_WF,      
ARF_OutCSel, 
ARF_OutDSel, 
ARF_FunSel,
ARF_RegSel, 
IR_LH,
IR_Write,
IROut, 
ALU_Flags,
Mem_WR,
Mem_CS,          
MuxASel,
MuxBSel,        
MuxCSel,
Clock);

        //RF

    input wire [2:0] RF_OutASel; 
    input wire [2:0] RF_OutBSel; 
    input wire [2:0] RF_FunSel; 
    input wire [3:0] RF_RegSel;
    input wire [3:0] RF_ScrSel;
    wire [15:0] OutA; 
    wire [15:0] OutB;

    /////// ARF
    input wire [1:0] ARF_OutCSel;
    input wire [1:0] ARF_OutDSel;
    input wire [2:0] ARF_FunSel;
    input wire [2:0] ARF_RegSel;
    wire [15:0] OutC;
    wire [15:0] OutD;

    //IR
    input wire IR_LH;
    input wire IR_Write;
    output wire [15:0] IROut;  /// değişkenken outputa çevirdik

    ////// ALU
    input wire [4:0] ALU_FunSel;
    input wire ALU_WF;
    wire [15:0] ALUOut;
    output wire [3:0] ALU_Flags;

    //////// Memory
    input wire Mem_WR; //// WR
    input wire Mem_CS; //// CS
    wire [7:0] MemOut;

    // MUX A
    input wire [1:0] MuxASel;
    wire [15:0] MuxAOut;
    
    //MUX B
    input wire [1:0] MuxBSel;
    wire [15:0] MuxBOut;

    //MUX C
    input wire MuxCSel;
    wire [7:0] MuxCOut;
    
    input wire Clock;
    wire [15:0] Address;
    assign Address = OutD;


    Memory MEM(
        .Clock(Clock), 
        .Address(Address), 
        .Data(MuxCOut), 
        .WR(Mem_WR), 
        .CS(Mem_CS), 
        .MemOut(MemOut)
    );

    ArithmeticLogicUnit ALU(
        .A(OutA), 
        .B(OutB), 
        .FunSel(ALU_FunSel), 
        .ALUOut(ALUOut), 
        .FlagsOut(ALU_Flags),
        .WF(ALU_WF),
        .Clock(Clock)
    );

    MUX_4TO1 _MUXA(
        .S(MuxASel), 
        .D0(ALUOut), 
        .D1(OutC), 
        .D2({8'b0,MemOut}), 
        .D3({8'b0,IROut[7:0]}), 
        .Y(MuxAOut)
    );


    MUX_4TO1 _MUXB(
        .S(MuxBSel), 
        .D0(ALUOut), 
        .D1(OutC), 
        .D2({8'b0,MemOut}), 
        .D3({8'b0,IROut[7:0]}), 
        .Y(MuxBOut)
    );


    MUX_2TO1 _MUXC(
        .S(MuxCSel), 
        .D0(ALUOut[7:0]), 
        .D1(ALUOut[15:8]), 
        .Y(MuxCOut)
    );


    InstructionRegister IR(
            .Clock(Clock),
            .I(MemOut),
            .Write(IR_Write),
            .LH(IR_LH),
            .IROut(IROut)
        );

    /////////// RF
    RegisterFile RF(
        .Clock(Clock),
        .I(MuxAOut), 
        .OutASel(RF_OutASel), 
        .OutBSel(RF_OutBSel), 
        .FunSel(RF_FunSel), 
        .RegSel(RF_RegSel), 
        .ScrSel(RF_ScrSel), 
        .OutA(OutA), 
        .OutB(OutB)
    );

    AddressRegisterFile ARF(
        .I(MuxBOut), 
        .OutCSel(ARF_OutCSel), 
        .OutDSel(ARF_OutDSel), 
        .FunSel(ARF_FunSel), 
        .RegSel(ARF_RegSel),
        .OutC(OutC), 
        .OutD(Address), 
        .Clock(Clock)
    );
endmodule