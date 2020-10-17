library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity datapath is
    Port(Datapath_out : out std_logic_vector(0 to 31);
         CLK, RST : in std_logic;
         D_EN_WRITE, D_EN_READ1, D_EN_READ2, D_SEL_IMM_MUX, D_SEL_RD_MUX : in std_logic;
         E_SEL_OP1_MUX : in std_logic;
         E_SEL_OP2_MUX : in std_logic_vector(0 to 1);
         E_ALU_FUNC : in std_logic_vector(0 to 3);
         E_EN_WRITE_NOW : in std_logic;
         M_EN_READ, M_EN_WRITE, M_IS_LINK : in std_logic;
         W_SEL_WB_MUX : in std_logic;
         Opcode : out std_logic_vector(0 to 5);
         Func : out std_logic_vector(0 to 10);
         jump_taken_n : in std_logic;
         flush : in std_logic;
         stall_out : out std_logic);
end datapath;

architecture struct of datapath is
--Stages
component fetch_stage is
    Port(PC_in, instruction_word_in : in std_logic_vector(0 to 31);
         PC_out, NPC_out, IR_out : out std_logic_vector(0 to 31);
         CLK, RST, fetch_active, jump_taken_n, flush, stall: in std_logic);
end component;
component decode_stage is
    Port(NPC_in, IR_in, WB_datain : in std_logic_vector(0 to 31);
         WB_add : in std_logic_vector(0 to 4);
         EN_READ1, EN_READ2, EN_WRITE, decode_active, sel_imm_mux, sel_rd_mux, flush, CLK, RST : in std_logic;
         NPC_out, A_out, B_out, IMM_out : out std_logic_vector(0 to 31);
         C_out, Rd_out : out std_logic_vector(0 to 4);
         Opcode_out : out std_logic_vector(0 to 5);
         Func_out   : out std_logic_vector(0 to 10));
end component;
component execute_stage is
    Port(NPC_in, A_in, B_in, Imm_in : in std_logic_vector(0 to 31);
         C_in : in std_logic_vector(0 to 4);
         sel_op1_mux, execute_active, flush, CLK, RST : in std_logic;
         sel_op2_mux : in std_logic_vector(0 to 1);
         ALU_func : in std_logic_vector(0 to 3);
         ALU_output, B_out, NPC_out: out std_logic_vector(0 to 31);
         C_out : out std_logic_vector(0 to 4);
         rs1_is_zero : out std_logic);
end component;
component memory_stage is
    Port(ALU_in, DRAM_in : in std_logic_vector(0 to 31);
         C_in : in std_logic_vector(0 to 4);
         is_link, memory_active, flush, RST, CLK : in std_logic;
         LMD_out, ALU_out: out std_logic_vector(0 to 31);
         C_out : out std_logic_vector(0 to 4));
end component;
component writeback_stage is
    Port (LMD_out, ALU_out : in std_logic_vector(0 to 31);
          CLK, RST, flush, writeback_active, sel_wb_mux : in std_logic;
          WRITEBACK, DATAPATH_out : out std_logic_vector(0 to 31));
end component;
--Memories
component iram is
    Generic (RAM_DEPTH : integer := 48;
             I_SIZE : integer := 32);
    Port (Rst  : in  std_logic;
          Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
          Dout : out std_logic_vector(I_SIZE - 1 downto 0));
end component;
component dram is
    Port (ADDRESS, DATAIN : in std_logic_vector(0 to 31);
          CLK, RST, WE, RE : in std_logic;
          DATAOUT : out std_logic_vector(0 to 31));
end component;
--Hazard detection unit
component hazard_detection_unit is
    Port (Rs1, Rs2, Rt, Rt_EX, Rt_MEM: in std_logic_vector(0 to 4);
          Opcode : in std_logic_vector(0 to 5);
          Next_opcode : in std_logic_vector(0 to 5);
          CLK, M_EN_READ: in std_logic;
          STALL : out std_logic);
end component;
--Wires
signal pc_to_iram_wire, instruction_from_iram_wire : std_logic_vector(0 to 31);
signal ir_to_decode, npc_to_decode : std_logic_vector(0 to 31);
signal npc_to_fetch, npc_to_execute, alu_output_to_memory, b_to_memory : std_logic_vector(0 to 31);
signal data_wb_to_decode, a_to_execute, b_to_execute, 
       imm_to_execute, lmd_to_writeback, alu_out_to_writeback, data_from_dram : std_logic_vector(0 to 31);
signal addr_wb_to_decode, c_to_execute, rd_in_decode, c_to_memory: std_logic_vector(0 to 4);
signal opcode_to_cu : std_logic_vector(0 to 5);
signal func_to_cu : std_logic_vector(0 to 10);

signal fetch_active, decode_active, execute_active, memory_active, writeback_active : std_logic:= '1';
signal stall, rs1_is_zero, stall_tmp : std_logic := '0';

begin

stall_out <= NOT(stall);
fetch_active <= NOT(stall); 
Opcode<=instruction_from_iram_wire(0 to 5);
Func  <=instruction_from_iram_wire(21 to 31); 

fetch_s : fetch_stage Port Map (PC_in=> npc_to_fetch, instruction_word_in=> instruction_from_iram_wire,
    PC_out=> pc_to_iram_wire, NPC_out=> npc_to_decode, IR_out=> ir_to_decode,
    CLK=> CLK, RST=> RST, fetch_active=> fetch_active, jump_taken_n=> jump_taken_n, flush=> '0', stall=> stall);

iram_s : iram Port Map (Rst=> RST, Addr=> pc_to_iram_wire, Dout=> instruction_from_iram_wire);

decode_s : decode_stage Port Map (NPC_in=> npc_to_decode, IR_in=> ir_to_decode, WB_datain=> data_wb_to_decode,
    WB_add=> addr_wb_to_decode, EN_READ1=> D_EN_READ1, EN_READ2=> D_EN_READ2, EN_WRITE=> D_EN_WRITE, 
    decode_active=> decode_active, sel_imm_mux=> D_SEL_IMM_MUX, sel_rd_mux=> D_SEL_RD_MUX, flush=> flush, 
    CLK=> CLK, RST=> RST, NPC_out=> npc_to_execute, A_out=> a_to_execute, B_out=> b_to_execute, 
    IMM_out=> imm_to_execute, C_out=> c_to_execute, Rd_out=> rd_in_decode, Opcode_out=> opcode_to_cu,
    Func_out=> func_to_cu);    
    
execute_s : execute_stage Port map (NPC_in=> npc_to_execute, A_in=> a_to_execute, B_in=> b_to_execute,
    Imm_in=> imm_to_execute, C_in=> c_to_execute, sel_op1_mux=> E_SEL_OP1_MUX, execute_active=> execute_active,
    flush=> '0', CLK=> CLK, RST=> RST, sel_op2_mux=> E_SEL_OP2_MUX, ALU_func=> E_ALU_FUNC, 
    ALU_output=> alu_output_to_memory, B_out=> b_to_memory, NPC_out=> npc_to_fetch, C_out=> c_to_memory, 
    rs1_is_zero=> rs1_is_zero);    

memory_s : memory_stage Port Map (ALU_in=> alu_output_to_memory, DRAM_in=> data_from_dram, C_in=> c_to_memory,
    is_link=> M_IS_LINK, memory_active=> memory_active, flush=> '0', RST=> RST, CLK=> CLK, LMD_out=> lmd_to_writeback,
    ALU_out=> alu_out_to_writeback, C_out=> addr_wb_to_decode);

dram_s : dram Port Map (ADDRESS=> alu_output_to_memory, DATAIN=> b_to_memory, CLK=> CLK, RST=> RST, WE=> M_EN_WRITE,
    RE=> M_EN_READ, DATAOUT=> data_from_dram);
    
writeback_s : writeback_stage Port Map (LMD_out=> lmd_to_writeback, ALU_out=> alu_out_to_writeback, CLK=> CLK, RST=> RST,
    flush=> '0', writeback_active=> writeback_active, sel_wb_mux=> W_SEL_WB_MUX, WRITEBACK=> data_wb_to_decode, 
    DATAPATH_out=> Datapath_out);
    
hazard_s : hazard_detection_unit Port Map (Rs1=> ir_to_decode(6 to 10), Rs2=> ir_to_decode(11 to 15), Rt=> rd_in_decode, Rt_EX=> c_to_execute,
    Rt_MEM=> c_to_memory, Opcode=> ir_to_decode(0 to 5), Next_opcode=>instruction_from_iram_wire(0 to 5),  
    CLK=> CLK, M_EN_READ=> E_EN_WRITE_NOW, STALL=> stall);    
end struct;
