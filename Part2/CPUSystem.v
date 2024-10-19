`timescale 1ns / 1ps

module counter(Clock,reset,sc_reset,O, T);
    input wire Clock,reset,sc_reset;
    output reg [3:0] O = 4'b0;
    output reg [15:0] T;

    always@(posedge Clock)  
        begin

            if(reset || sc_reset) //reset is for end of operation
                begin
                O <= 4'h2; //we don't know why this works
                end
            else
                O <= O + 1;
        case(O)
            4'h0 : T = 16'h0000;
            4'h1 : T = 16'h0001;    // T0
            4'h2 : T = 16'h0002;    // T1
            4'h3 : T = 16'h0004;    // T2
            4'h4 : T = 16'h0008;    // T3
            4'h5 : T = 16'h0010;    // T4
            4'h6 : T = 16'h0020;    // T5
            4'h7 : T = 16'h0040;    // T6
            4'h8 : T = 16'h0080;    // T7
            4'h9 : T = 16'h0100;    // T8
            4'hA : T = 16'h0200;    // T9
            4'hB : T = 16'h0400;    // T10
            4'hC : T = 16'h0800;    // T11
            4'hD : T = 16'h1000;    // T12
            4'hE : T = 16'h2000;    // T13
            4'hF : T = 16'h4000;    // T14
            default : T = 16'h0001;
        endcase
            if(reset || sc_reset) 
                T=16'h0001; // go to T[0] when reset
    end
endmodule

module control_unit(Clock, IROut,ARF_FunSel,ARF_RegSel,ARF_OutCSel, ARF_OutDSel, 
    ALU_FlagsOut, ALU_FunSel, RF_OutASel, RF_OutBSel, RF_FunSel, RF_RegSel, RF_ScrSel,
    MuxASel, MuxBSel, MuxCSel, Mem_CS, Mem_WR, IR_LH, IR_Write, SC_Reset, ALU_WF, T);    
    input wire Clock;
    input wire [15:0] IROut;
    input wire [3:0] ALU_FlagsOut;
    reg [33:0] D;
    input wire SC_Reset; 

    output reg [2:0] ARF_FunSel;
    output reg [2:0] ARF_RegSel;
    output reg [1:0] ARF_OutDSel;
    output reg [1:0] ARF_OutCSel;
    output reg [4:0] ALU_FunSel;
    output reg ALU_WF;
    output reg [2:0] RF_OutASel;
    output reg [2:0] RF_OutBSel;
    output reg [2:0] RF_FunSel;
    output reg [3:0] RF_RegSel;
    output reg [3:0] RF_ScrSel;

    output reg [1:0] MuxASel;
    output reg [1:0] MuxBSel;
    output reg MuxCSel;

    output reg Mem_CS;
    output reg Mem_WR;
    output reg IR_LH;
    output reg IR_Write;

    output wire [15:0] T;

    reg [7:0] address;
    reg [1:0] RSEL;

    wire Z = ALU_FlagsOut[3];
    reg [3:0] DSTREG;
    reg Reset;
    wire [3:0] SREG1 = address[5:3];
    wire [3:0] SREG2 = address[2:0];
    wire [3:0] S = RSEL[1];

    wire [3:0] temp; //decimal value for clock operations

    counter SC(Clock,Reset,SC_Reset,temp, T);   
    
    
    always @(*)
        begin
            if(SC_Reset)
            begin
            Mem_WR <= 1'b0;
            Mem_CS <= 1'b1;
            ARF_FunSel <= 3'b011;
            RF_FunSel <= 3'b011;
            RF_RegSel <= 4'b0000;
            ARF_RegSel <= 3'b001; //AR and PC enabled
            RF_ScrSel <= 4'b0000;
            _ALUSystem.ARF.SP.Q = 16'h00ff;
            end
        end


    always @(T[0]) //fetch low
    begin
            ARF_RegSel <= 3'b011; // PC
            ARF_FunSel <= 3'b001; // inc
            Reset <= 0;
            ARF_OutDSel <= 2'b01;
            ARF_OutCSel <= 2'bZ;
            Mem_CS <= 1'b0;
            Mem_WR <= 1'b0;
            IR_LH <= 1'b0;
            IR_Write <= 1'b1;
            RF_ScrSel <= 4'b1111;
    end

    always @(T[1]) //fetch high
    begin
        if(T[1])
        begin
            ARF_OutDSel <= 2'b01;
            ARF_OutCSel <= 2'bZ;
            Mem_CS <= 1'b0;
            Mem_WR <= 1'b0;
            IR_LH <= 1'b1;
            IR_Write <= 1'b1;
            RF_RegSel <= 4'b1111;
            ARF_RegSel <= 3'b011; // PC
            ARF_FunSel <= 3'b001; // inc
        end
    end
    
    always @(T[2]) //death state for an optimum decode operation
        begin
            ARF_FunSel <= 3'bZ; // inc
            IR_Write <= 1'b0;
          end
           
    always @(T[3]) //decode and execution starts
        begin
            IR_Write <= 1'b0;
            if(T[3])
            begin
            case(IROut[15:10])
            8'h00 : D = 96'h0000000001;  // D[0]
            8'h01 : D = 96'h0000000002;
            8'h02 : D = 96'h0000000004;
            8'h03 : D = 96'h0000000008;
            8'h04 : D = 96'h0000000010;
            8'h05 : D = 96'h0000000020;
            8'h06 : D = 96'h0000000040;
            8'h07 : D = 96'h0000000080;
            8'h08 : D = 96'h0000000100;
            8'h09 : D = 96'h0000000200;
            8'h0A : D = 96'h0000000400;
            8'h0B : D = 96'h0000000800;
            8'h0C : D = 96'h0000001000;
            8'h0D : D = 96'h0000002000;
            8'h0E : D = 96'h0000004000;
            8'h0F : D = 96'h0000008000;
            8'h10 : D = 96'h0000010000;
            8'h11 : D = 96'h0000020000;
            8'h12 : D = 96'h0000040000;
            8'h13 : D = 96'h0000080000;
            8'h14 : D = 96'h0000100000;
            8'h15 : D = 96'h0000200000;
            8'h16 : D = 96'h0000400000;
            8'h17 : D = 96'h0000800000;
            8'h18 : D = 96'h0001000000;
            8'h19 : D = 96'h0002000000;
            8'h1A : D = 96'h0004000000;
            8'h1B : D = 96'h0008000000;
            8'h1C : D = 96'h0010000000;
            8'h1D : D = 96'h0020000000;
            8'h1E : D = 96'h0040000000;
            8'h1F : D = 96'h0080000000;
            8'h20 : D = 96'h0100000000;
            8'h21 : D = 96'h0200000000; // D[33] için
            default : D = 0;
            endcase

            address <= IROut[7:0];
            RSEL <= IROut[9:8];
            end
        end
 


/////////////////// EXECUTION PART //////////////////////


    always @(T or D or address or RSEL ) begin 
        
        ARF_FunSel <= 3'bZ;
        ARF_RegSel <= 4'bZ;
        RF_FunSel <= 3'bZ;
        RF_RegSel <= 4'bZ;
        RF_ScrSel <= 4'bZ;
        Mem_WR <= 0;
        MuxASel <= 2'bZ;
        MuxBSel <= 2'bZ;
        RF_OutASel <= 3'bZ;
        RF_OutBSel <= 3'bZ;
        ALU_WF <= 1'bZ;

        DSTREG <= {RSEL[0], address[7:6]}; //decode DSTREG


        // SREG1 from RF
        if (
        (
        ((D[5] || D[6] || D[7] || D[8] || D[9] || D[10] || D[11] || D[14] || D[24]) && T[4])
        || ((D[12] || D[13] || D[15] || D[16] || D[21] || D[22] || D[23] || D[25] || D[26] || D[27] || D[28] || D[29]) && T[5])
        )
        )
        begin

            // ALU_A <- SREG1
            if(SREG1[2]) RF_OutASel <= {~SREG1[2], SREG1[1:0]};
            else RF_OutASel <= 3'b100; // S1 

        end

        // SREG2 from RF
        if (
        (
        ((D[12] || D[13] ||  D[15] || D[16] || D[21] || D[22] || D[23] || D[25] || D[26] || D[27] || D[28] || D[29]) && T[5])
        )
        ) begin
            // ALU_B <- SREG2
            if(SREG2[2]) RF_OutBSel <= {~SREG2[2], SREG2[1:0]};
            else RF_OutBSel <= 3'b101; // S2               
        end

        // SREG1 from ARF
        if (
        ((D[5] || D[6] || D[7] || D[8] || D[9] || D[10] || D[11] || D[12] || D[13] || D[14] || D[15] || D[16] || D[21] || D[22] || D[23] || D[24] || D[25] || D[26] || D[27] || D[28] || D[29]) && T[3]) &&
        SREG1[2] == 0)
        begin
            // ALU_A <- SREG1

            case (SREG1[1:0])
                2'b00: ARF_OutCSel <= 2'b00; // ARF Output is PC
                2'b01: ARF_OutCSel <= 2'b00; // ARF Output is PC
                2'b10: ARF_OutCSel <= 2'b11; // ARF Output is SP
                2'b11: ARF_OutCSel <= 2'b10; // ARF Output is AR
                default: ARF_OutCSel <= 2'b11;
            endcase
            
            MuxASel <= 2'b01; // OutC

            RF_FunSel <= 3'b010; // load

            RF_ScrSel <= 4'b0111; // S1
        end

        // SREG2 from ARF
        if (
        (((D[12] || D[13] ||  D[15] || D[16] || D[21] || D[22] ||  D[23] || D[25] || D[26] || D[27] || D[28] || D[29]) && T[4])) &&
        SREG2[2] == 0)
         begin
            // RF_S1 <- SREG2
            case (SREG2[1:0])
                2'b00: ARF_OutCSel <= 2'b00; // ARF Output is PC
                2'b01: ARF_OutCSel <= 2'b00; // ARF Output is PC
                2'b10: ARF_OutCSel <= 2'b11; // ARF Output is SP
                2'b11: ARF_OutCSel <= 2'b10; // ARF Output is AR
                default: ARF_OutCSel <= 2'b11;
            endcase

            MuxASel <= 2'b01;

            RF_FunSel <= 3'b010;  // load

            RF_ScrSel <= 4'b1011; // S2
        end



        // DSTREG is in RF     
        if (
        (
        ((D[5] || D[6]) && T[4]) ||
        ((D[7] || D[8] || D[9] || D[10] || D[11] || D[14] || D[24]) && T[4]) ||
        ((D[12] || D[13] ||  D[15] || D[16] || D[21] || D[22] || D[23] || D[25] || D[26] || D[27] || D[28] || D[29]) && T[5])
        )   
            &&  DSTREG[2] == 1) 
        begin

            MuxASel <= 2'b00;
            RF_FunSel <= 3'b010;  // load

            // D5
            if((D[5] || D[6]) && T[4])
            begin
                if(SREG1[2]) MuxASel <= 2'b00;
                else MuxASel <= 2'b01;
            end  


            case (DSTREG[1:0])
                2'b00 : RF_RegSel <= 4'b0111; // R1
                2'b01 : RF_RegSel <= 4'b1011; // R2
                2'b10 : RF_RegSel <= 4'b1101; // R3
                2'b11 : RF_RegSel <= 4'b1110; // R4
                default: RF_RegSel <= 4'bZZZZ;
            endcase
        end

        // DSTREG is in ARF
        if (
        (((D[5] || D[6]) && T[4]) ||
        ((D[7] || D[8] || D[9] || D[10] || D[11]|| D[14] || D[24]) && T[4]) ||
        ((D[12] || D[13] || D[15] || D[16] || D[21] || D[22] || D[23] || D[25] || D[26] || D[27] || D[28] || D[29]) && T[5])
        
        )
        &&
            DSTREG[2] == 0 ) 
        begin

            MuxBSel <= 2'b00;
            ARF_FunSel <= 3'b010;  // load

            // D5
            if((D[5] || D[6]) && T[4])
                begin
                    if(SREG1[2]) MuxBSel <= 2'b00;
                    else MuxBSel <= 2'b01;
                end        

            case (DSTREG[1:0])
                2'b01: ARF_RegSel <= 3'b011; // PC
                2'b00: ARF_RegSel <= 3'b011; // PC
                2'b10: ARF_RegSel <= 3'b110; // SP
                2'b11: ARF_RegSel <= 3'b101; // AR
                default: ARF_RegSel <= 4'bZZZZ;
            endcase
        end


        // To increment the DSTREG, we know that it has the value of SREG1
        if ((D[5] && T[5]))
        begin
            if (DSTREG[2] == 0) begin // If DSTREG is in ARF
                    case (DSTREG[1:0])
                        2'b01: ARF_RegSel <= 3'b011; // PC
                        2'b00: ARF_RegSel <= 3'b011; // PC
                        2'b10: ARF_RegSel <= 3'b110; // SP
                        2'b11: ARF_RegSel <= 3'b101; // AR
                        default: ARF_RegSel <= 4'bZZZZ;
                    endcase
                ARF_FunSel <= 3'b001; // Increment
            end 
            else begin // If DSTREG is in RF
                    case (DSTREG[1:0])
                        2'b00 : RF_RegSel <= 4'b0111; // R1
                        2'b01 : RF_RegSel <= 4'b1011; // R2
                        2'b10 : RF_RegSel <= 4'b1101; // R3
                        2'b11 : RF_RegSel <= 4'b1110; // R4
                    default: RF_RegSel <= 4'bZZZZ;
                endcase
                RF_FunSel <= 3'b001; // Increment
            end
        end


        // To decrement the DSTREG, we know that it has the value of SREG1
        if ((D[6] && T[5]))
        begin
            if (DSTREG[2] == 0) begin // If DSTREG is in ARF
                case (DSTREG[1:0])
                    2'b01: ARF_RegSel <= 3'b011; // PC
                    2'b00: ARF_RegSel <= 3'b011; // PC
                    2'b10: ARF_RegSel <= 3'b110; // SP
                    2'b11: ARF_RegSel <= 3'b101; // AR
                default: ARF_RegSel <= 4'bZZZZ;
                endcase
                ARF_FunSel <= 3'b000; // Decrement
                end 
            else
                begin // If DSTREG is in RF
                case (DSTREG[1:0])
                    2'b00 : RF_RegSel <= 4'b0111; // R1
                    2'b01 : RF_RegSel <= 4'b1011; // R2
                    2'b10 : RF_RegSel <= 4'b1101; // R3
                    2'b11 : RF_RegSel <= 4'b1110; // R4
                default: RF_RegSel <= 4'bZZZZ;
                endcase
                RF_FunSel <= 3'b000; // Decrement
            end
        end




        //RF_OutASel

        if((D[30] && T[4]) || (D[30] && T[5]))
        begin
            RF_OutASel <= 3'b100; // S1
        end
        if(((D[33] || D[0]) && T[5]) || (D[1] && T[5] && !Z) || (D[2] && T[5] && Z))
        begin
            RF_OutASel <= 3'b100; // S1
        end
        if(((D[4] || D[19])&& T[3]) || ((D[4] || D[19]) && T[4]) || ((D[33]) && T[6]) || ((D[33]) && T[7]) || ((D[30]) && T[6]))
        begin
            RF_OutASel <= {1'b0, RSEL};
        end

//////////////////////////////////////////////////////////////////////////////////////////////////////

        ///  D[7]vs'de RF to ALU from S1 
        if((((D[7] || D[8] || D[9] || D[10] || D[11] || D[24]) && T[4]) 
        || ((D[12] || D[13]) && T[5]))
        && ~SREG1[2]
        )
        begin
            RF_OutASel <= 3'b100;  // S1
        end

        // rf out b sel
        if((((D[12] || D[13]) && T[5]))
        && ~SREG2[2]
        )
        begin
            RF_OutBSel <= 3'b101;  // S2
        end
              

        if(((D[33] || D[0] || D[1] || D[2]) && T[5]))
        begin
            RF_OutBSel <= 3'b101; // s2
        end

 //////////////////////////////////////////////////////////////////////////////////////////////////////               

        //RF_FunSel
        if(((D[0] || D[30] || D[33] || D[18]) && T[3]) || (D[0] || (D[33]) && T[4]) ||(D[1] && T[3] && !Z) ||(D[2] && T[3] && Z) || (D[21] && T[5]))
        begin
            RF_FunSel <= 3'b010; //load
        end
        else if(((D[3] || D[20]) && T[3]) || ((D[32]) && T[4]))
        begin
            RF_FunSel <= 3'b101; // write low
        end
        else if(((D[17]) && T[3]) || (( D[32]) && T[5]) || ((D[3]) && T[4]))
        begin
            RF_FunSel <= 3'b110; // write high
        end


//////////////////////////////////////////////////////////////////////////////////////////////////////


        //RF_RegSel
        if(0)
        begin
            RF_RegSel <= 4'b0111; // R1
        end
        else if(0)
        begin
            RF_RegSel <= 4'b1011; // R2
        end

        if(((D[3] || D[17] || D[18] || D[20]) && T[3]) || ((D[3] || D[32]) && T[4])  || ((D[30] || D[32]) && T[5]))
        begin
            case (RSEL)
            2'b00: RF_RegSel <= 4'b0111; // R
            2'b01: RF_RegSel <= 4'b1011; // R
            2'b10: RF_RegSel <= 4'b1101; // R
            2'b11: RF_RegSel <= 4'b1110; // R
        endcase
        end


//////////////////////////////////////////////////////////////////////////////////////////////////////


        //RF_SrcSel
        if(((D[30] || D[0] || D[33] || D[1] || D[2]) && T[3]))
        begin
            RF_ScrSel <= 4'b0111; // S1
        end
        else if((D[33] || D[0] || D[1] || D[2]) && T[4])
        begin
            RF_ScrSel <= 4'b1011; // S2
        end

//////////////////////////////////////////////////////////////////////////////////////////////////////


        //ALUFunSel
        if((D[0] && T[5]) || (D[1] && T[5] && !Z) || (D[2] && T[5] && Z))
        begin
            ALU_FunSel <= 5'b10100; //A+B
        end
        if(
        ((D[6] || D[4] || D[5] || D[19]) && T[4]) ||
        ((D[19]) && T[3]) || 
        ((D[24] || D[30] || D[4]) && T[4]) ||
        ((D[30]) && T[5]) ||
        ((D[33] || D[30]) && T[6]) || 
        ((D[33]) && T[7])
        )
        begin
            ALU_FunSel <= 5'b10000; // A=>A
            if(D[24] && T[4]) ALU_WF <= 1'b1;
        end
        if(D[7] && T[4])
        begin
            ALU_FunSel <= 5'b11011; // LSL
        end
        if(D[8] && T[4])
        begin
            ALU_FunSel <= 5'b11100; // LSR
        end
        if(D[9] && T[4])
        begin
            ALU_FunSel <= 5'b11101; // ASR
        end
        if(D[10] && T[4])
        begin
            ALU_FunSel <= 5'b11110; // CSL
        end
        if(D[11] && T[4])
        begin
            ALU_FunSel <= 5'b11111; // CSR
        end
        if((D[12] || D[27]) && T[5])
        begin
            ALU_FunSel <= 5'b10111; // AND
            if(D[27]) ALU_WF <= 1;
        end
        if((D[13] || D[28]) && T[5])
        begin
            ALU_FunSel <= 5'b11000; // OR
            if(D[28]) ALU_WF <= 1;
        end
        if(D[14] && T[4])
        begin
            ALU_FunSel <= 5'b10010; // NOT
        end
        if((D[15] || D[29]) && T[5])
        begin
            ALU_FunSel <= 5'b11001; // XOR
            if(D[29]) ALU_WF <= 1;
        end
        if(D[16] && T[5])
        begin
            ALU_FunSel <= 5'b11010; // NAND
        end
        if((D[21] || D[25] || D[33])&& T[5])
        begin
            ALU_FunSel <= 5'b10100; // ADD
            if(D[25]) ALU_WF <= 1;
        end
        if(D[22] && T[5])
        begin
            ALU_FunSel <= 5'b10101; // ADD + carry
        end
        if((D[23] || D[26]) && T[5])
        begin
            ALU_FunSel <= 5'b10110; // SUB
            if(D[26]) ALU_WF <= 1;
        end

//////////////////////////////////////////////////////////////////////////////////////////////////////
        
        //ALU_WF
        if(!(D[0] || D[1] || D[2] || D[3] || D[4] || D[18] || D[17] || D[19] || D[20] || D[30] || D[31] || D[32] ||D[33]))
            begin
                if(S) ALU_WF <= 1'b1;
            end

//////////////////////////////////////////////////////////////////////////////////////////////////////

        //ARFOutCSel
        if(((D[0] || D[30]) && T[3]) || (D[1] && T[3] && !Z) || (D[2] && T[3] && Z))
        begin
            ARF_OutCSel <= 2'b00;  // 01 de olabilir  PC
        end
        if(((D[33]) && T[3]))
        begin
            ARF_OutCSel <= 2'b10;  // AR
        end

//////////////////////////////////////////////////////////////////////////////////////////////////////    

        //ARF_OutDSel
        if(((D[32] || D[33] || D[19]) && T[4]) || ((D[18] || D[19])&& T[3]) || ((D[32]) && T[5]) || ((D[33]) && T[6]))
        begin
            ARF_OutDSel <= 2'b10;   // AR
        end
        if(((D[30] ||  D[3] || D[4])&& T[4]) || ((D[30]) && T[5]) || ((D[3] || (D[4] || D[31]) && T[3])))
        begin
            ARF_OutDSel <= 2'b11;    // SP
        end
       
//////////////////////////////////////////////////////////////////////////////////////////////////////


        //ARF_FunSel
        if(((D[32] || D[33]) && T[3]) || ((D[30]) && T[6]) || ((D[0]|| D[33]) && T[5]) || (D[1] && T[5] && !Z) || (D[2] && T[5] && Z))
        begin
            ARF_FunSel <= 3'b010;  // load
        end
        else if(D[31] && T[3])
        begin
            ARF_FunSel <= 3'b101; // write low
        end
        else if(D[31] && T[5])
        begin
            ARF_FunSel <= 3'b110; // write high
        end

        if(((D[3] || D[19]) && T[3]) || ((D[3] || D[31] ) && T[4]) || ((D[32]) && T[4]) || ((D[33] || D[31]) && T[6]))
        begin
            ARF_FunSel <= 3'b001; // inc
        end
        if(((D[4] || D[30]) && T[4]) || (D[4] && T[3]) || (D[30] && T[5]))
        begin
            ARF_FunSel <= 3'b000; // dec
        end

//////////////////////////////////////////////////////////////////////////////////////////////////////

        //ARF_RegSel
        if(((D[32] || D[33] || D[19]) && T[3]) || ((D[32]) && T[4]) || (( D[33]) && T[5]) || ((D[33]) && T[6]))
        begin
            ARF_RegSel <= 3'b101;  //AR
        end
        else if(((D[4] || D[3] )&& T[3]) || ((D[4] || D[3] || D[30] || D[31]) && T[4]) || ( D[30] && T[5]) || (D[31] && T[6]))
        begin
            ARF_RegSel <= 3'b110; //SP
        end
        else if(((D[0] || D[31] ) && T[5]) || ((D[30]) && T[6]) || (D[1] && T[5] && !Z) || (D[2] && T[5] && Z) || (D[31] && T[3]))
        begin
            ARF_RegSel <= 3'b011; // PC
        end


//////////////////////////////////////////////////////////////////////////////////////////////////////


        //Mem_WR
        if(((D[18] || D[31] || D[3]) && T[3]) || ((D[3] || D[32] || D[33]) && T[4]) || ((D[32]) && T[5]))
        begin
            Mem_WR <= 1'b0;
        end
        
        if(((D[4] || D[19]) && T[3]) || ((D[4] || D[19] || D[30]) && T[4]) || ((D[30]) && T[5]) || ((D[33]) && T[6]) || ((D[33]) && T[7]))
        begin
            Mem_WR <= 1'b1;
        end

//////////////////////////////////////////////////////////////////////////////////////////////////////        

        //MuxAsel
        if(((D[0] || D[30] || D[33]) && T[3])|| (D[1] && T[3] && !Z) || (D[2] && T[3] && Z))
        begin
            MuxASel <= 2'b01;   // OutC
        end
        if(((D[3] || D[18]) && T[3]) || ((D[3] || D[32] || D[33]) && T[4]) || ((D[32]) && T[5]))
        begin
            MuxASel <= 2'b10; // MemOut
        end
        if(((D[17] || D[20]) && T[3]) || ((D[0]) && T[4]) || (D[1] && T[4] && !Z) || (D[2] && T[4] && Z))
        begin
            MuxASel <= 2'b11; // IROut
        end

//////////////////////////////////////////////////////////////////////////////////////////////////////


        //MuxBSel
        if(((D[32] || D[33]) && T[3]))
        begin
            MuxBSel <= 2'b11;
        end

        if(((D[31]) && T[3]) || ((D[31]) && T[5]))
        begin
            MuxBSel <= 2'b10;
        end

        if(((D[0] || D[33]) && T[5]) || ((D[30]) && T[6]) || (D[1] && T[5] && !Z) || (D[2] && T[5] && Z))
        begin
            MuxBSel <= 2'b00;
        end


//////////////////////////////////////////////////////////////////////////////////////////////////////


        //MuxCSel
        if((( D[19]) && T[3]) || ((D[4]) && T[4]) || ((D[33]) && T[6]) || (D[30] && T[5]))
        begin
            MuxCSel <= 1'b0;
        end
        if(((D[4] &&T[3])|| ( D[19]) && T[4]) || ((D[30]) && T[4]) || ((D[33]) && T[7]))
        begin
            MuxCSel <= 1'b1;
        end

//////////////////////////////////////////////////////////////////////////////////////////////////////
        /*
            D0  ends at T5-
            D1  ends at T5-
            D2  ends at T5-
            D3  ends at T4-
            D4  ends at T4-
            D5  ends at T5-
            D6  ends at T5-
            D7  ends at T4-
            D8  ends at T4-
            D9  ends at T4-
            D10 ends at T4-
            D11 ends at T4-
            D12 ends at T5-
            D13 ends at T5-
            D14 ends at T4-
            D15 ends at T5-
            D16 ends at T5-
            D17 ends at T3-
            D18 ends at T3-
            D19 ends at T4-
            D20 ends at T3-
            D21 ends at T5-
            D22 ends at T5-
            D23 ends at T5-
            D24 ends at T4-
            D25 ends at T5-
            D26 ends at T5-
            D27 ends at T5-
            D28 ends at T5-
            D29 ends at T5-
            D30 ends at T6-
            D31 ends at T3-
            D32 ends at T5-
            D33 ends at T7-
           
        */

        //Reset for every operation at the end of each operation
        if (
            (T[3] && (D[17] || D[18] || D[20] )) ||
            (T[4] && (D[3] || D[4] || D[7] || D[8] || D[9] || D[10] || D[11] || D[14] || D[19] || D[24])) ||
            (T[5] && (D[0] || D[5] || D[6] || (D[1] && !Z) || (D[2] && Z) || D[12] || D[13] || D[15] || D[16] || D[21] || D[22] || D[23] || D[25] || D[26] || D[27] || D[28] || D[29] || D[32])) || 
            (T[6] && (D[30] || D[31] )) ||
            (T[7] && (D[33]))
            )
             begin
            Reset <=1;
        end
    end
endmodule

//Combine control unit and ALUSystem
module CPUSystem(input wire Clock, input wire Reset, output wire [7:0] T, output wire [15:0] IR_Out);
    wire [2:0] RF_OutASel;
    wire [2:0] RF_OutBSel;
    wire [2:0] RF_FunSel;
    wire [3:0] RF_RegSel;
    wire [3:0] RF_ScrSel;
    wire [4:0] ALU_FunSel;
    wire [1:0] ARF_OutCSel; 
    wire [1:0] ARF_OutDSel; 
    wire [2:0] ARF_FunSel; 
    wire [2:0] ARF_RegSel;
    wire IR_LH; 
    wire IR_Write;
    wire Mem_WR;
    wire Mem_CS;
    wire [1:0] MuxASel;
    wire [1:0] MuxBSel;
    wire MuxCSel;
    wire [3:0] ALU_FlagsOut;
    wire ALU_WF;

    ALUSystem _ALUSystem(
        .RF_OutASel(RF_OutASel), 
        .RF_OutBSel(RF_OutBSel), 
        .RF_FunSel(RF_FunSel),
        .RF_RegSel(RF_RegSel),
        .RF_ScrSel(RF_ScrSel),
        .ALU_FunSel(ALU_FunSel),
        .ALU_WF(ALU_WF),
        .ARF_OutCSel(ARF_OutCSel), 
        .ARF_OutDSel(ARF_OutDSel), 
        .ARF_FunSel(ARF_FunSel),
        .ARF_RegSel(ARF_RegSel),
        .IR_LH(IR_LH),
        .IR_Write(IR_Write),
        .IROut(IR_Out),
        .Mem_WR(Mem_WR),
        .Mem_CS(Mem_CS),
        .MuxASel(MuxASel),
        .MuxBSel(MuxBSel),
        .MuxCSel(MuxCSel),
        .ALU_Flags(ALU_FlagsOut),
        .Clock(Clock));
        
    control_unit CU(
        .Clock(Clock),
        .IROut(IR_Out),
        .ARF_FunSel(ARF_FunSel), 
        .ARF_RegSel(ARF_RegSel),
        .ARF_OutDSel(ARF_OutDSel), 
        .ARF_OutCSel(ARF_OutCSel),
        .ALU_FlagsOut(ALU_FlagsOut), 
        .ALU_FunSel(ALU_FunSel), 
        .RF_OutASel(RF_OutASel), 
        .RF_OutBSel(RF_OutBSel), 
        .RF_FunSel(RF_FunSel), 
        .RF_RegSel(RF_RegSel), 
        .RF_ScrSel(RF_ScrSel),
        .MuxASel(MuxASel), 
        .MuxBSel(MuxBSel), 
        .MuxCSel(MuxCSel), 
        .Mem_CS(Mem_CS), 
        .Mem_WR(Mem_WR), 
        .IR_LH(IR_LH),
        .ALU_WF(ALU_WF),
        .IR_Write(IR_Write),
        .SC_Reset(~Reset),
        .T(T));
endmodule