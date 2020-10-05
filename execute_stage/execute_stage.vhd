library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity execute_stage is
    Generic (NBIT : integer := 32);
    Port (NPC_in, A_in, B_in, Imm_in : in std_logic_vector(0 to NBIT-1);
          C_in : in std_logic_vector(0 to 4);
          sel_op1_mux, sel_op2_mux, EN_ALU_output, EN_NPC, EN_zero_reg, EN_B_reg, EN_C_reg, CLK, RST : in std_logic;
          ALU_func : in std_logic_vector(0 to 3);
          NPC_out, ALU_output, B_out: out std_logic_vector(0 to NBIT-1);
          C_out : out std_logic_vector(0 to 4);
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
--Dram
component dram is
    Generic (RAM_DEPTH : integer := 48;
             D_SIZE : integer := 32);
    Port (ADDR, DATAIN : in std_logic_vector(0 to D_SIZE-1);
          DOUT : out std_logic_vector(0 to D_SIZE-1);
          RST, READ, WRITE : in std_logic);             
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
signal NPC_bus, A_bus, B_bus, out_op1_mux, out_op2_mux, ALU_out_bus : std_logic_vector(0 to NBIT-1);
signal comparator_out_array, is_zero_array : std_logic_vector(0 to 0);
signal comparator_out : std_logic;
begin

NPC_bus <= NPC_in;
--NPC_out <= NPC_bus;
A_bus <= A_in;
B_bus <= B_in;

comparator_out_array(0) <= comparator_out;
is_zero <= is_zero_array(0);

op1_mux : mux2to1_generic Generic Map (NBIT=> 32) Port Map (A=> NPC_bus, B=> A_bus, SEL=> sel_op1_mux, OUTPUT=> out_op1_mux);
op2_mux : mux2to1_generic Generic Map (NBIT=> 32) Port Map (A=> B_in, B=> Imm_in, SEL=> sel_op2_mux, OUTPUT=> out_op2_mux);

zero_comparator : comparator_generic Generic Map (NBIT=> 32) Port Map (A=> A_bus, B=>X"00000000", EN=>'1', EQ=> comparator_out, GT=> open, LT=> open);

alu : simple_alu_generic Generic Map (NBIT=> 32) Port Map (FUNC=> ALU_func, INPUT1=> out_op1_mux, INPUT2=> out_op2_mux, ALU_OUT=> ALU_out_bus);

NPC_reg : register_generic Generic Map (NBIT=> 32) Port Map (D=> NPC_bus, Q=> NPC_out, CLK=> CLK, RST=> RST, EN=> EN_NPC);
cond_reg : register_generic Generic Map (NBIT=> 1) Port Map (D=> comparator_out_array, Q=> is_zero_array, CLK=> CLK, RST=> RST, EN=> EN_zero_reg);
alu_out_reg : register_generic Generic Map (NBIT=> 32) Port Map (D=> ALU_out_bus, Q=> ALU_output, CLK=> CLK, RST=> RST, EN=> EN_ALU_output);
B_reg : register_generic Generic Map (NBIT=> 32) Port Map (D=> B_bus, Q=> B_out, CLK=> CLK, RST=> RST, EN=> EN_B_reg);
C_reg : register_generic Generic Map (NBIT=> 5) Port Map (D=> C_in, Q=> C_out, CLK=> CLK, RST=> RST, EN=> EN_C_reg);
end rtl;
