library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity execute_stage is
    Generic (NBIT : integer := 32);
    Port (NPC_in, A_in, B_in, Imm_in, C_in : in std_logic_vector(0 to NBIT-1);
          sel_op1_mux, sel_op2_mux, EN_ALU_output, CLK, RST : in std_logic;
          ALU_func : in std_logic_vector(0 to 3);
          NPC_out, ALU_output, C_out : out std_logic_vector(0 to NBIT-1);
          is_zero : out std_logic );
end execute_stage;

architecture rtl of execute_stage is
--Components
--Register
component register_generic is
    Generic (NBIT : integer := 32);
    Port (D: in std_logic_vector(0 to NBIT-1);
          Q: out std_logic_vector(0 to NBIT-1);
          CLK, RST, EN : in std_logic);
end component;
--Multiplexer
component mux2to1_generic is
    Generic (NBIT : integer := 32);
    Port (A, B : in std_logic_vector(0 to NBIT-1);
          SEL : in std_logic;
          OUTPUT : out std_logic_vector(0 to NBIT-1));
end component;
--Comparator
component comparator_generic is
    Generic (NBIT: integer := 32);
    Port (A, B : in std_logic_vector(0 to NBIT-1);
          EN : in std_logic;
          EQ, GT, LT : out std_logic);
end component;
--Simple alu
component simple_alu_generic is
    Generic (NBIT : integer := 32);
	port (	FUNC : IN std_logic_vector(0 to 3);
			INPUT1, INPUT2 : IN std_logic_vector(0 to NBIT-1);
			ALU_OUT : OUT std_logic_vector(0 to NBIT-1));
end component;

--Internal wires
signal NPC_bus, A_bus, out_op1_mux, out_op2_mux, ALU_out_bus : std_logic_vector(0 to NBIT-1);

begin

NPC_bus <= NPC_in;
NPC_out <= NPC_bus;
A_bus <= A_in;
C_out <= C_in;

op1_mux : mux2to1_generic Generic Map (NBIT=> 32) Port Map (A=> NPC_bus, B=> A_bus, SEL=> sel_op1_mux, OUTPUT=> out_op1_mux);
op2_mux : mux2to1_generic Generic Map (NBIT=> 32) Port Map (A=> B_in, B=> Imm_in, SEL=> sel_op2_mux, OUTPUT=> out_op2_mux);

zero_comparator : comparator_generic Generic Map (NBIT=> 32) Port Map (A=> A_bus, B=>X"00000000", EN=>'1', EQ=> is_zero, GT=> open, LT=> open);

alu : simple_alu_generic Generic Map (NBIT=> 32) Port Map (FUNC=> ALU_func, INPUT1=> out_op1_mux, INPUT2=> out_op2_mux, ALU_OUT=> ALU_out_bus);

alu_out_reg : register_generic Generic Map (NBIT=> 32) Port Map (D=> ALU_out_bus, Q=> ALU_output, CLK=> CLK, RST=> RST, EN=> EN_ALU_output);
end rtl;
