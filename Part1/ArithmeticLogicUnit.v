`timescale 1ns / 1ps

module ArithmeticLogicUnit(A, B, FunSel, WF, Clock, ALUOut, FlagsOut);
    input wire [15:0] A;
    input wire [15:0] B;
    input wire [4:0] FunSel;
    input wire WF;
    input wire Clock;
    output reg [15:0] ALUOut;
    output reg [3:0] FlagsOut;

    reg [7:0] ALU_8bit;
    wire [7:0] A_8bit = A[7:0];
    wire [7:0] B_8bit = B[7:0];

    reg temp_Z = 0;
    reg temp_C = 0;
    reg temp_N = 0;
    reg temp_O = 0;

    always @(*) begin
            case (FunSel)

        //8 bit//
        ///////////////////////////// 

            5'b00000: // ALUOut = A
                begin
                    ALU_8bit = A_8bit;
                    
                    // FLAG UPDATE
                    temp_N = ALU_8bit[7]; // Negative
                end

            5'b00001: // ALUOut = B
                begin
                    ALU_8bit = B_8bit;

                    // FLAG UPDATE
                    temp_N = ALU_8bit[7];
                end

            //-----------------------//

            5'b00010: // ALUOut = NOT A
                begin
                    ALU_8bit = ~A_8bit;

                    // FLAG UPDATE
                    temp_N = ALU_8bit[7];
                end

            5'b00011: // ALUOut = NOT B
                begin
                    ALU_8bit = ~B_8bit;

                    // FLAG UPDATE
                    temp_N = ALU_8bit[7];
                end

            //-----------------------//
            
            
            5'b00100: // ALUOut = A + B 
                begin
                    temp_O = 0;
                    {temp_C, ALU_8bit} = {1'b0, A_8bit} + {1'b0, B_8bit};

                    // FLAG UPDATE
                    if ((A_8bit[7] == B_8bit[7]) && (B_8bit[7] != ALU_8bit[7])) begin
                        temp_O = 1;
                    end
                    temp_N = ALU_8bit[7];    
                end

            5'b00101: // ALUOut = A + B + Carry
                begin
                    temp_O = 0;
                    {temp_C, ALU_8bit} = {1'b0, A_8bit} + {1'b0, B_8bit} + {8'd0, FlagsOut[2]};

                    // FLAG UPDATE
                    if ((A_8bit[7] == B_8bit[7]) && (B_8bit[7] != ALU_8bit[7])) begin
                        temp_O = 1;
                    end
                    temp_N = ALU_8bit[7];
                end

            5'b00110: // ALUOut = A - B
                begin
                    temp_O = 0;
                    {temp_C, ALU_8bit} = {1'b0, A_8bit} + {1'b0, (~B_8bit + 8'd1)};
                    
                    // FLAG UPDATE
                    if ((B_8bit[7] == ALU_8bit[7]) && (B_8bit[7] != A_8bit[7])) begin
                        temp_O = 1;
                    end
                    temp_N = ALU_8bit[7];
                end

            

            //-----------------------//

            5'b00111: // ALUOut = A AND B
                begin
                    ALU_8bit = A_8bit & B_8bit;

                    // FLAG UPDATE
                    temp_N = ALU_8bit[7];
                end

            5'b01000: // ALUOut = A OR B
                begin
                    ALU_8bit = A_8bit | B_8bit;

                    // FLAG UPDATE
                    temp_N = ALU_8bit[7];
                end
                
             5'b01001: // ALUOut = A XOR B
                begin
                    ALU_8bit = A_8bit ^ B_8bit;
               
                    // FLAG UPDATE
                    temp_N = ALU_8bit[7];
                end
                           
            5'b01010: // ALUOut = A NAND B
                begin
                    ALU_8bit = ~(A_8bit & B_8bit);

                    // FLAG UPDATE
                    temp_N = ALU_8bit[7];
                end

           

            //-----------------------//

            5'b01011: // ALUOut = LSL A
                begin
                    temp_C = A_8bit[7];
                    ALU_8bit = A_8bit;
                    ALU_8bit = ALU_8bit << 1;

                    temp_N = ALU_8bit[7];
                end

            5'b01100: // ALUOut = LSR A
                begin
                    temp_C = A_8bit[0];
                    ALU_8bit = A_8bit;
                    ALU_8bit = ALU_8bit >> 1;

                    // FLAG UPDATE
                    temp_N = ALU_8bit[7];    
                end

            
            5'b01101: // ALUOut = ASR A
                begin
                    temp_C = A_8bit[0];
                    ALU_8bit = A_8bit;
                    ALU_8bit = ALU_8bit >> 1;
                    ALU_8bit[7] = ALU_8bit[6];
                    
                end
               
            5'b01110: // ALUOut = CSL A
                begin
                    ALU_8bit = {A_8bit[6:0],FlagsOut[2]};
                    temp_C = A_8bit[7];
           
                    // FLAG UPDATE
                    temp_N = ALU_8bit[7];
                end

            5'b01111: // ALUOut = CSR A
                begin
                    ALU_8bit = {FlagsOut[2], A_8bit[7:1]};
                    temp_C = A_8bit[0];

                    // FLAG UPDATE
                    temp_N = ALU_8bit[7];
                end


            /////////////////////
            //16-bit//

            5'b10000: // ALUOut = A
                begin
                    ALUOut = A;

                    // FLAG UPDATE
                    temp_N = ALUOut[15];
                end

            5'b10001: // ALUOut = B
                begin
                    ALUOut = B;

                    // FLAG UPDATE
                    temp_N = ALUOut[15];
                end

            //-----------------------//

            5'b10010: // ALUOut = NOT A
                begin
                    ALUOut = ~A;

                    // FLAG UPDATE
                    temp_N = ALUOut[15];
                end

            5'b10011: // ALUOut = NOT B
                begin
                    ALUOut = ~B;

                    // FLAG UPDATE
                    temp_N = ALUOut[15];
                end
                
            5'b10100: // ALUOut =  A + B
                begin 
                    temp_O = 0; 
                    {temp_C, ALUOut} = {1'b0, A} + {1'b0, B};
                                   
                    // Check for overflow condition
                    if ((A[15] == B[15]) && (B[15] != ALUOut[15])) 
                        begin
                        temp_O = 1; // Set overflow flag if overflow occurred
                        end
                                       
                    // Check for negative result
                    temp_N = ALUOut[15];
                    end
               
           
                
            5'b10101: // ALUOut = A + B + Carry
                begin
                temp_O = 0;
                {temp_C, ALUOut} = {1'b0, A} + {1'b0, B} + {16'd0, FlagsOut[2]};
                
                // FLAG UPDATE
                if ((A[15] == B[15]) && (B[15] != ALUOut[15])) begin
                    temp_O = 1;
                    end
                temp_N = ALUOut[15];
                end
                
            5'b10110: // ALUOut = A - B
                begin
                temp_O = 0;
                {temp_C, ALUOut} = {1'b0, A} + {1'b0, (~B + 16'd1)};
                                
                // FLAG UPDATE
                if ((B[15] == ALUOut[15]) && (B[15] != A[15])) begin
                    temp_O = 1;
                    end
                temp_N = ALUOut[15];
                end
                
                 
            
            //-----------------------//

            5'b10111: // ALUOut = A AND B
                begin
                    ALUOut = A & B;

                    // FLAG UPDATE
                    temp_N = ALUOut[15];
                end

            5'b11000: // ALUOut = A OR B
                begin
                    ALUOut = A | B;

                    // FLAG UPDATE
                    temp_N = ALUOut[15];
                end

            
            5'b11001: // ALUOut = A XOR B
                begin
                    ALUOut = A ^ B;

                    // FLAG UPDATE
                    temp_N = ALUOut[15];
                end

            5'b11010: // ALUOut = A NAND B
                begin
                    ALUOut = ~(A & B);

                    // FLAG UPDATE
                    temp_N = ALUOut[15];
                end

            //-----------------------//

            5'b11011: // ALUOut = LSL A
                begin
                    temp_C = A[15];
                    ALUOut = A;
                    ALUOut = ALUOut << 1;

                    // FLAG UPDATE
                    temp_N = ALUOut[15];
                end

            5'b11100: // ALUOut = LSR A
                begin
                    temp_C = A[0];
                    ALUOut = A;
                    ALUOut = ALUOut >> 1;

                    // FLAG UPDATE
                    temp_N = ALUOut[15];   
                end

            5'b11101: // ALUOut = ASR A
                begin
                    temp_C=A[0];
                    ALUOut = A;
                    ALUOut = ALUOut >> 1;
                    ALUOut[15] = ALUOut[14];
                end

            5'b11110: // ALUOut = CSL A
                begin
                    ALUOut = {A[14:0],FlagsOut[2]};
                    temp_C = A[15];
           
                    // FLAG UPDATE
                    temp_N = ALUOut[15];
                end

            

            5'b11111: // ALUOut = CSR A
                begin
                    ALUOut = {FlagsOut[2], A[15:1]};
                    temp_C = A[0];

                    // FLAG UPDATE
                    temp_N = ALUOut[15];
                end

            default: // Return A
                begin
                    ALUOut = A;
                end

            endcase

            if (FunSel[4]) begin
                if (ALUOut == 16'd0) begin // Zero
                    temp_Z = 1;
                end 
                else begin
                    temp_Z = 0;
                end
            end
            else begin
                if (ALU_8bit == 8'd0) begin // Zero
                    temp_Z = 1;
                end 
                else begin
                    temp_Z = 0;
                end
                ALUOut = {8'd0, ALU_8bit};
            end
    end

    always @(posedge Clock) begin
        if(WF) begin
            FlagsOut[3]=temp_Z;
            
            if(FunSel==5'b00100||FunSel==5'b00101||FunSel==5'b00110||FunSel==5'b10100||FunSel==5'b10101||FunSel==5'b10110)
            begin
            FlagsOut[2]=temp_C;
            FlagsOut[0]=temp_O;
            end
            if(FunSel==5'b11101||FunSel==5'b01101)
              begin
                
               end
               else  FlagsOut[1]=temp_N;

            if(FunSel==5'b11011||FunSel==5'b11100||FunSel==5'b11101||FunSel==5'b11110||FunSel==5'b11111||FunSel==5'b01011||FunSel==5'b01100||FunSel==5'b01101||FunSel==5'b01110||FunSel==5'b01111)
              begin
                FlagsOut[2]=temp_C;
               end
            
         end
    end

endmodule