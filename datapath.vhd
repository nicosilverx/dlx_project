library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity datapath is
    Port ( 
           D_EN_RF, D_EN_READ1, D_EN_READ2, D_SEL_IMM_MUX, 
           D_EN_A, D_EN_B, D_EN_C, D_EN_IMM, D_EN_NPC, D_EN_WRITE, D_SEL_RD_MUX, D_IS_JUMP: in std_logic;
           E_SEL_OP1_MUX, E_SEL_OP2_MUX : in std_logic;
           E_ALU_FUNC : in std_logic_vector(0 to 3);
           E_EN_NPC, E_EN_ZERO_REG, E_EN_ALU_OUTPUT,
           E_EN_B_REG, E_EN_C_REG, E_EN_COMPARATOR, E_TYPE_OF_COMP, E_IS_JUMP : in std_logic;
           M_EN_READ, M_EN_WRITE, M_EN_LMD_REG, M_EN_ALU_OUTPUT, M_EN_C_REG, M_IS_LINK : in std_logic;
           W_SEL_WB_MUX, W_EN_DATAPATH_OUT : in std_logic;
           CLK, RST : in std_logic;
           D_OPCODE : out std_logic_vector(0 to 5);
           D_FUNC : out std_logic_vector(0 to 10);
           datapath_out, IR : out std_logic_vector(0 to 31));
end datapath;

architecture rtl of datapath is
--Components: datapath stages
component fetch_stage_wrapper is
    Generic (NBIT : integer := 32);
    Port(PC_in : in std_logic_vector(0 to NBIT-1);
         NPC_out, IR_out : out std_logic_vector(0 to NBIT-1);
         CLK, RST, PC_EN, NPC_EN, IR_EN, sel_pc_mux, flush_stage: in std_logic);
end component;

component decode_stage is
    Generic (NBIT : integer := 32);
    Port (NPC_in, IR_in, WB_datain : in std_logic_vector(0 to NBIT-1);
          WB_add : in std_logic_vector(0 to 4);
          NPC_out, A_out, B_out, IMM_out : out std_logic_vector(0 to NBIT-1);
          C_out : out std_logic_vector(0 to 4);
          Opcode_out : out std_logic_vector(0 to 5);
          Func_out   : out std_logic_vector(0 to 10);
          EN_READ1, EN_READ2, EN_WRITE, EN_RF, EN_A, EN_B, EN_C, EN_IMM, EN_NPC, sel_imm_mux, sel_rd_mux, flush_stage, CLK, RST : in std_logic); 
end component;

component execute_stage is
    Generic (NBIT : integer := 32);
    Port (NPC_in, A_in, B_in, Imm_in : in std_logic_vector(0 to NBIT-1);
          C_in : in std_logic_vector(0 to 4);
          sel_op1_mux, sel_op2_mux, EN_ALU_output, EN_zero_reg, EN_B_reg, EN_C_reg, EN_comparator, type_of_comp, is_jump, flush_stage, CLK, RST : in std_logic;
          ALU_func : in std_logic_vector(0 to 3);
          ALU_output, B_out, NPC_out: out std_logic_vector(0 to NBIT-1);
          C_out : out std_logic_vector(0 to 4);
          is_zero : out std_logic );
end component;

component memory_stage is
    Generic (NBIT : integer := 32);
    Port (ALU_output, B_in : in std_logic_vector(0 to NBIT-1);
          C_in : in std_logic_vector(0 to 4);
          CLK, RST, EN_READ, EN_WRITE, EN_LMD_reg, EN_ALU_output_reg, EN_C_reg, is_link, flush_stage: in std_logic;
          NPC_out, LMD_out, ALU_reg_out : out std_logic_vector(0 to NBIT-1);
          C_out : out std_logic_vector(0 to 4));
end component;

component writeback_stage is
    Generic (NBIT: integer := 32);
    Port (LMD_out, ALU_out : in std_logic_vector(0 to NBIT-1);
          CLK, RST, EN_DATAPATH_out, sel_wb_mux, flush_stage : in std_logic;
          WRITEBACK, DATAPATH_out : out std_logic_vector(0 to NBIT-1));
end component;

--Internal wires
--Fetch to Decode
signal NPC_to_decode, IR_to_decode : std_logic_vector(0 to 31);
--Decode to Execute
signal NPC_to_execute, A_to_execute, B_to_execute, IMM_to_execute : std_logic_vector(0 to 31);
signal C_to_execute : std_logic_vector(0 to 4);
--Execute to Memory
signal NPC_to_memory, ALU_to_memory, B_to_memory : std_logic_vector(0 to 31);
signal COND_to_memory : std_logic;
signal C_to_memory : std_logic_vector(0 to 4);
--Memory to Writeback/Fetch/Decode
signal NPC_to_fetch, LMD_to_writeback, ALU_to_writeback : std_logic_vector(0 to 31);
signal C_to_decode : std_logic_vector(0 to 4);
--Writeback to Decode/OUT
signal DATAPATH_to_out, WRITEBACK_to_decode : std_logic_vector(0 to 31);

signal dp_flush_v, dp_flush, flush1, flush2, flush3, flush4 : std_logic := '1'; --attivo basso
--signal flush_counter_active : std_logic := '0';
signal flush_counter : integer := 1;

begin

FlushProc:process(CLK, RST, E_IS_JUMP)
variable flush_counter_active : std_logic := '0';
begin
--    if(CLK='1' AND CLK'EVENT) then
--        if(E_IS_JUMP='1') then
--            flush_counter_active := '1';
--            flush_counter <= 1;
--            dp_flush_v <= '0';
--        end if;
        
--        if(flush_counter_active = '1') then
--            flush_counter <= flush_counter - 1;
--            dp_flush_v <= '0';
--        end if;
        
--        if(flush_counter = 0) then
--            flush_counter <= 1;
--            flush_counter_active:='0';
--            dp_flush_v <= '1';
--        end if;
--    end if;
end process FlushProc;

dp_flush <= NOT(D_IS_JUMP) AND RST;
datapath_out <= DATAPATH_to_out; 
IR <= IR_to_decode;

FlushPip:process(CLK, dp_flush)
begin
    if(CLK='1' AND CLK'EVENT) then
        flush1 <= dp_flush;
        flush2 <= flush1;
        flush3 <= flush2;
        flush4 <= flush3;
    end if;
end process FlushPip;
fetch_s : fetch_stage_wrapper Generic Map (NBIT=> 32) Port Map (
    PC_in=> NPC_to_fetch, NPC_out=> NPC_to_decode, IR_out=> IR_to_decode, 
    CLK=> CLK, RST=> RST, PC_EN=> '1', NPC_EN=> '1', IR_EN=> '1', sel_pc_mux=> COND_to_memory, flush_stage=> flush1);

decode_s : decode_stage Generic Map (NBIT=> 32) Port Map (
    NPC_in=> NPC_to_decode, IR_in=> IR_to_decode, WB_datain=> WRITEBACK_to_decode, 
    WB_add=> C_to_decode, NPC_out=> NPC_to_execute, A_out=> A_to_execute, B_out=> B_to_execute, IMM_out=> IMM_to_execute,
    C_out=> C_to_execute, Opcode_out=> D_OPCODE, Func_out=> D_FUNC, EN_READ1=> D_EN_READ1, EN_READ2=> D_EN_READ2,
     EN_WRITE=> D_EN_WRITE, EN_RF=> D_EN_RF, EN_A=> D_EN_A, EN_B=> D_EN_B, EN_C=> D_EN_C, EN_IMM=> D_EN_IMM, 
     EN_NPC=> D_EN_NPC, sel_imm_mux=> D_SEL_IMM_MUX, sel_rd_mux=> D_SEL_RD_MUX, flush_stage=> flush2, CLK=> CLK, RST=> RST);
     
execute_s : execute_stage Generic Map (NBIT=> 32) Port Map (
    NPC_in=> NPC_to_execute, A_in=> A_to_execute, B_in=> B_to_execute, Imm_in=> IMM_to_execute,
    C_in=> C_to_execute, sel_op1_mux=>E_SEL_OP1_MUX, sel_op2_mux=> E_SEL_OP2_MUX, EN_ALU_output=> E_EN_ALU_OUTPUT, 
    EN_zero_reg=> E_EN_ZERO_REG, EN_B_reg=> E_EN_B_REG, EN_C_reg=> E_EN_C_REG, EN_comparator=> E_EN_COMPARATOR,
    type_of_comp=> E_TYPE_OF_COMP, is_jump=> E_IS_JUMP, flush_stage=> flush3, CLK=> CLK, RST=> RST, ALU_func=> E_ALU_FUNC,
    ALU_output=> ALU_to_memory, B_out=> B_to_memory, NPC_out=> NPC_to_fetch, C_out=> C_to_memory, is_zero=> COND_to_memory);     
    
memory_s : memory_stage Generic Map (NBIT=> 32) Port Map (
    ALU_output=> ALU_to_memory, B_in=> B_to_memory, C_in=> C_to_memory,
    CLK=> CLK, RST=> RST, EN_READ=> M_EN_READ, EN_WRITE=> M_EN_WRITE, EN_LMD_reg=> M_EN_LMD_REG, 
    EN_ALU_output_reg=> M_EN_ALU_OUTPUT, EN_C_reg=> M_EN_C_REG, is_link=> M_IS_LINK, flush_stage=> flush4,  
    NPC_out=> open, LMD_out=> LMD_to_writeback, 
    ALU_reg_out=> ALU_to_writeback, C_out=> C_to_decode);
    
writeback_s : writeback_stage Generic Map (NBIT=> 32) Port Map (
    LMD_out=> LMD_to_writeback, ALU_out=> ALU_to_writeback, CLK=> CLK, RST=> RST, EN_DATAPATH_out=> W_EN_DATAPATH_OUT,
    sel_wb_mux=> W_SEL_WB_MUX, flush_stage=> flush4, WRITEBACK=> WRITEBACK_to_decode, DATAPATH_out=> DATAPATH_to_out);      
end rtl;
