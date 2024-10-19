`timescale 1ns / 1ps

module Register(
    input wire Clock,        // Clock input        
    input wire [2:0] FunSel, // Function Select signals
    input wire [15:0] I,     // 16-bit input data
    input wire E,            // Enable signal
    output reg [15:0] Q      // 16-bit output data (register value)
);
always @(posedge Clock)
    begin
    if (E)
    begin // Check if enable is high
        case (FunSel)
            3'b000: Q <= Q - 1;            // Decrement
            3'b001: Q <= Q + 1;            // Increment
            3'b010: Q <= I;                // Load
            3'b011: Q <= 16'b0;            // Clear
            3'b100: Q <= {8'b0, I[7:0]};   // Clear upper byte, write lower byte
            3'b101: Q <= {Q[15:8], I[7:0]};// Write lower byte only
            3'b110: Q <= {I[7:0], Q[7:0]}; // Write upper byte only
            3'b111: Q <= { {8{I[7]}}, I[7:0] }; // Sign extend bit 7 to upper byte, write lower byte
            default: Q <= Q;               // Retain value if FunSel is not recognized
        endcase
    end
    else
    begin
    Q <= Q;  
    end
    // If enable is low, retain the current value of Q
end

endmodule