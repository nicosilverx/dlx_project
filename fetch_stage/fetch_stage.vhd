library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fetch_stage is
    Generic (NBIT : integer := 32);
    Port(PC_in, instruction_word_in : in std_logic_vector(0 to NBIT-1);
         PC_out, NPC_out, IR_out : out std_logic_vector(0 to NBIT-1);
         CLK, RST, PC_EN, NPC_EN, IR_EN : in std_logic);
end fetch_stage;

architecture rtl of fetch_stage is
--Register
component register_generic is
    Generic (NBIT : integer := 32);
    Port (D: in std_logic_vector(0 to NBIT-1);
          Q: out std_logic_vector(0 to NBIT-1);
          CLK, RST, EN : in std_logic);
end component;
--Adder
component adder_generic is
    Generic (NBIT : integer := 32);
    Port (A, B : in std_logic_vector(0 to NBIT-1);
          S    : out std_logic_vector(0 to NBIT-1));
end component;

--Internal wires
signal PC_value, adder_to_NPC : std_logic_vector(0 to NBIT-1);

begin
--Component declarations
PC : register_generic Generic Map (NBIT=> 32) Port Map (D=> PC_in, Q=> PC_value, CLK=> CLK, RST=> RST, EN=> PC_EN);
NPC: register_generic Generic Map (NBIT=> 32) Port Map (D=> adder_to_NPC, Q=> NPC_out, CLK=> CLK, RST=> RST, EN=> NPC_EN);
IR : register_generic Generic Map (NBIT=> 32) Port Map (D=> instruction_word_in, Q=> IR_out, CLK=> CLK, RST=> RST, EN=> IR_EN);
PC_adder : adder_generic Generic Map (NBIT=> 32) Port Map (A=> PC_value, B=>X"00000004", S=> adder_to_NPC);

PC_out <= PC_value;
end rtl;
