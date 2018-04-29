module controlPath
    #(
        parameter N = 8,        // Data bus width
        parameter A_SIZE = 3,   // ALU function width
        parameter O_SIZE = 6,   // OpCode width
        parameter P_SIZE = 5,   // Program memory address width
        parameter R_SIZE = 3,   // GPR address width

        // Instruction = opCode(O) + dest(R) + source(R) + imm/addr(N)
        parameter I_SIZE = O_SIZE + (2*R_SIZE) + N
    )
    (
        // Outputs
        // Demo
        output wire [(P_SIZE-1):0] displayPC,

        // Control
        output wire writeReg,
        output cpuConfig::aluFunc_t aluFunc,
        output wire aluImmediate,
        // Data
        output wire [(R_SIZE-1):0] opD, opS,
        output wire [(N-1):0] opT,

        // Clock/reset
        input wire clk, nRst
    );

    
    // Instruction wires
    wire [(I_SIZE-1):0] instruction;
    cpuConfig::opCode_t opCode;
    assign {opCode, opD, opS, opT} = instruction;


    // Program counter IO
    wire pcInc, pcBranchAbs, pcBranchRel;
    wire [(P_SIZE-1):0] pcAddressOut, pcBranchAddress;
    assign pcBranchAddress = opT[(P_SIZE-1):0];


    assign displayPC = pcAddressOut;
    

    // Program counter instance
    programCounter
        #(
            .P_SIZE(P_SIZE)
        ) pc
        (
            .addressOut(pcAddressOut),

            .branchAddressIn(pcBranchAddress),
            .inc(pcInc),
            .branchAbs(pcBranchAbs),
            .branchRel(pcBranchRel),

            .clk(clk),
            .nRst(nRst)
        );


    // Program memory instance
    programMemory
        #(
            .I_SIZE(I_SIZE),
            .P_SIZE(P_SIZE)
        ) pm
        (
            .instructionOut(instruction),

            .addressIn(pcAddressOut)
        );


    // Decoder instance
    decoder
        #(
            .A_SIZE(A_SIZE),
            .O_SIZE(O_SIZE)
        ) de
        (
            .aluFunc(aluFunc),
            .aluImmediate(aluImmediate),
            .pcInc(pcInc),
            .pcBranchAbs(pcBranchAbs),
            .pcBranchRel(pcBranchRel),
            .writeReg(writeReg),
            
            .opCode(opCode)
        );


endmodule
