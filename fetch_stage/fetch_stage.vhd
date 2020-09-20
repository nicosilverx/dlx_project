library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fetch_stage is
    Generic (NBIT : integer := 32);
    Port( next_pc, instruction_word : in std_logic_vector(0 to NBIT-1);
          SEL_MUX1, PC_EN, IR_EN, CLK, RST: in std_logic;
          IR_out, PC_out, PC_new : out std_logic_vector(0 to NBIT-1));
end fetch_stage;

architecture rtl of fetch_stage is
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
--Adder
component adder_generic is
    Generic (NBIT : integer := 32);
    Port (A, B : in std_logic_vector(0 to NBIT-1);
          S    : out std_logic_vector(0 to NBIT-1));
end component;

--Internal wires
signal mux_to_pc, pc_to_adder, adder_to_mux : std_logic_vector(0 to NBIT-1);

begin
--Component declarations
PC : register_generic Generic Map (NBIT=> 32) Port Map (D=> mux_to_pc, Q=> pc_to_adder, CLK=> CLK, RST=> RST, EN=> PC_EN);
IR : register_generic Generic Map (NBIT=> 32) Port Map (D=> instruction_word, Q=> IR_out, CLK=> CLK, RST=> RST, EN=> IR_EN);
adder : adder_generic Generic Map (NBIT=> 32) Port Map (A=> pc_to_adder, B=> X"00000001", S=> adder_to_mux); --aumentare di 1 o 4??
mux : mux2to1_generic Generic Map (NBIT=> 32) Port Map (A=> next_pc, B=> adder_to_mux, SEL=> SEL_MUX1, OUTPUT=> mux_to_pc);
PC_new <= adder_to_mux;
end rtl;
