library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity execute_stage is
    Port(NPC_in, A_in, B_in, Imm_in : in std_logic_vector(0 to 31);
         C_in : in std_logic_vector(0 to 4);
         sel_op1_mux, execute_active, flush, CLK, RST : in std_logic;
         sel_op2_mux : in std_logic_vector(0 to 1);
         ALU_func : in std_logic_vector(0 to 3);
         ALU_output, B_out, NPC_out: out std_logic_vector(0 to 31);
         C_out : out std_logic_vector(0 to 4);
         rs1_is_zero : out std_logic);
end execute_stage;

architecture struct of execute_stage is
--Components
component register_generic is
    Generic (NBIT : integer := 32;
             EDGE : std_logic := '1');
    Port (D: in std_logic_vector(0 to NBIT-1);
          Q: out std_logic_vector(0 to NBIT-1);
          CLK, RST, EN : in std_logic);
end component;
component mux2to1 is
    Generic (NBIT : integer := 32);
    Port (A, B : in std_logic_vector(0 to NBIT-1);
          SEL : in std_logic;
          OUTPUT : out std_logic_vector(0 to NBIT-1));
end component;
component mux4to1 is
    Port (A, B, C, D : in std_logic_vector(0 to 31);
          SEL : in std_logic_vector(0 to 1);
          OUTPUT : out std_logic_vector(0 to 31));
end component;
component alu is
    Port (FUNC : IN std_logic_vector(0 to 3);
		  INPUT1, INPUT2 : IN std_logic_vector(0 to 31);
		  ALU_OUT : OUT std_logic_vector(0 to 31);
		  INPUT1_IS_ZERO : out std_logic);
end component;
--Wires
signal internal_reset : std_logic := '1';
signal rs1_zero_to_rs1_zero_out : std_logic := '0';
signal op1_out_mux, op2_out_mux, alu_to_alu_out : std_logic_vector(0 to 31) := (OTHERS=>'0');

begin
internal_reset <= RST AND NOT(flush);

--Op muxes
op1_mux : mux2to1 Port Map (A=> NPC_in, B=> A_in, SEL=> sel_op1_mux, OUTPUT=> op1_out_mux);
op2_mux : mux4to1 Port Map (A=> B_in, B=> IMM_in, C=> X"00000004", D=> X"00000000", SEL=> sel_op2_mux, OUTPUT=> op2_out_mux); 
--Alu
alu_1 : alu Port Map (FUNC=> ALU_func, INPUT1=> op1_out_mux, INPUT2=> op2_out_mux, ALU_OUT=> alu_to_alu_out, INPUT1_IS_ZERO=> rs1_zero_to_rs1_zero_out);
--NPC
NPC_reg : register_generic Port Map (D=> NPC_in, Q=> NPC_out, CLK=> CLK, RST=> internal_reset, EN=> execute_active);
--Rs1 zero
rs1_zero : register_generic Generic Map (NBIT=>1) Port Map (D(0)=>rs1_zero_to_rs1_zero_out, Q(0)=> rs1_is_zero, CLK=> CLK, RST=> internal_reset, EN=> execute_active);
--ALU_out
alu_out_reg : register_generic Port Map (D=> alu_to_alu_out, Q=> ALU_output, CLK=> CLK, RST=> internal_reset, EN=> execute_active);
--B
B_reg : register_generic Port Map (D=> B_in, Q=> B_out, CLK=> CLK, RST=> internal_reset, EN=> execute_active);
--C
C_reg : register_generic Generic Map (NBIT=> 5) Port Map (D=> C_in, Q=> C_out, CLK=> CLK, RST=> internal_reset, EN=> execute_active);
end struct;
