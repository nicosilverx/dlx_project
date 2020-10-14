library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fetch_stage is
    Generic (NBIT : integer := 32);
    Port(PC_in, instruction_word_in : in std_logic_vector(0 to NBIT-1);
         PC_out, NPC_out, IR_out : out std_logic_vector(0 to NBIT-1);
         CLK, RST, PC_EN, NPC_EN, IR_EN, sel_pc_mux, insert_nop: in std_logic);
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
--Mux
component mux2to1_generic is
    Generic (NBIT : integer := 32);
    Port (A, B : in std_logic_vector(0 to NBIT-1);
          SEL : in std_logic;
          OUTPUT : out std_logic_vector(0 to NBIT-1));
end component;
--Internal wires
signal PC_to_PC, PC_value, adder_to_NPC, ir_mux_out: std_logic_vector(0 to NBIT-1);

begin
--Component declarations
ir_mux : mux2to1_generic Generic Map (NBIT=> 32) Port Map (A=> X"54000000", B=> instruction_word_in, SEL=> insert_nop, 
    OUTPUT=> ir_mux_out);

PC : register_generic Generic Map (NBIT=> 32) Port Map (D=> PC_to_PC, Q=> PC_value, CLK=> CLK, RST=> RST, EN=> PC_EN);
NPC: register_generic Generic Map (NBIT=> 32) Port Map (D=> adder_to_NPC, Q=> NPC_out, CLK=> CLK, RST=> RST, EN=> NPC_EN);
--NPC_out <= adder_to_NPC;
IR : register_generic Generic Map (NBIT=> 32) Port Map (D=> ir_mux_out, Q=> IR_out, CLK=> CLK, RST=> RST, EN=> IR_EN);
PC_adder : adder_generic Generic Map (NBIT=> 32) Port Map (A=> PC_value, B=>X"00000004", S=> adder_to_NPC);

PC_mux : mux2to1_generic Generic Map (NBIT=> 32) Port Map (A=> adder_to_NPC, B=> PC_in, SEL=> sel_pc_mux, OUTPUT=> PC_to_PC);
PC_out <= PC_value;
end rtl;
