library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fetch_decode_wrapper is
    Generic (NBIT : integer := 32);
    Port (PC_in, DATA_WR : in std_logic_vector(0 to NBIT-1);
          ADD_WR : in std_logic_vector(0 to 4);
          CLK, RST, PC_EN, NPC_EN, IR_EN, EN_READ1, EN_READ2, EN_WRITE, EN_RF, EN_A, EN_B, EN_C, EN_IMM, EN_NPC, sel_imm_mux : in std_logic;
          NPC_out, A_out, B_out, IMM_out : out std_logic_vector(0 to NBIT-1);
          C_out : out std_logic_vector(0 to 4);
          Opcode_out : out std_logic_vector(0 to 5);
          Func_out   : out std_logic_vector(0 to 10));
end fetch_decode_wrapper;

architecture rtl of fetch_decode_wrapper is
--Components
component fetch_stage_wrapper is
    Generic (NBIT : integer := 32);
    Port(PC_in : in std_logic_vector(0 to NBIT-1);
         NPC_out, IR_out : out std_logic_vector(0 to NBIT-1);
         CLK, RST, PC_EN, NPC_EN, IR_EN : in std_logic);
end component;

component decode_stage is
    Generic (NBIT : integer := 32);
    Port (NPC_in, IR_in, WB_datain : in std_logic_vector(0 to NBIT-1);
          WB_add : in std_logic_vector(0 to 4);
          NPC_out, A_out, B_out, IMM_out : out std_logic_vector(0 to NBIT-1);
          C_out : out std_logic_vector(0 to 4);
          Opcode_out : out std_logic_vector(0 to 5);
          Func_out   : out std_logic_vector(0 to 10);
          EN_READ1, EN_READ2, EN_WRITE, EN_RF, EN_A, EN_B, EN_C, EN_IMM, EN_NPC, sel_imm_mux, CLK, RST : in std_logic); 
end component;

--Internal wires
signal NPC_wire, IR_wire : std_logic_vector(0 to NBIT-1);

begin

fetch: fetch_stage_wrapper Generic Map (NBIT=> 32) 
    Port Map (PC_in=> PC_in, NPC_out=> NPC_wire, IR_out=> IR_wire,
        CLK=> CLK, RST=> RST, PC_EN=> PC_EN, NPC_EN=> NPC_EN, IR_EN=> IR_EN);

decode: decode_stage Generic Map (NBIT=> 32)
    Port Map (NPC_in=> NPC_wire, IR_in=> IR_wire, WB_datain=> DATA_WR,
              WB_add=> ADD_WR, 
              NPC_out=> NPC_out, A_out=> A_out, B_out=> B_out, IMM_out=> IMM_out,
              C_out=> C_out,
              Opcode_out=> Opcode_out,
              Func_out=> Func_out,
              EN_READ1=> EN_READ1, EN_READ2=> EN_READ2, EN_WRITE=> EN_WRITE, EN_RF=> EN_RF, EN_A=> EN_A,
              EN_B=> EN_B, EN_C=> EN_C, EN_IMM=> EN_IMM, EN_NPC=> EN_NPC, sel_imm_mux=> sel_imm_mux, CLK=> CLK, RST=> RST);   

end rtl;
