library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fetch_stage is
    Port(PC_in, instruction_word_in : in std_logic_vector(0 to 31);
         PC_out, NPC_out, IR_out : out std_logic_vector(0 to 31);
         CLK, RST, fetch_active, jump_taken_n, flush, stall: in std_logic);
end fetch_stage;

architecture struct of fetch_stage is
--Components
component adder is
    Port (A, B : in std_logic_vector(0 to 31);
          S    : out std_logic_vector(0 to 31));
end component;
--Mux2to1
component mux2to1 is
    Generic (NBIT : integer := 32);
    Port (A, B : in std_logic_vector(0 to NBIT-1);
          SEL : in std_logic;
          OUTPUT : out std_logic_vector(0 to NBIT-1));
end component;
--Register
component register_generic is
    Generic (NBIT : integer := 32;
             EDGE : std_logic := '1');
    Port (D: in std_logic_vector(0 to NBIT-1);
          Q: out std_logic_vector(0 to NBIT-1);
          CLK, RST, EN : in std_logic);
end component;
--Wires
signal pc_mux_to_pc, pc_to_iram, adder_to_npc, stall_mux_to_adder : std_logic_vector(0 to 31) := (OTHERS=>'0');
signal internal_reset : std_logic := '1';

begin
PC_out <= pc_to_iram;
internal_reset <= RST AND NOT(flush);

stall_mux : mux2to1 Port Map (A=> X"00000000", B=>X"00000004", SEL=> stall, OUTPUT=> stall_mux_to_adder);
PC_mux : mux2to1 Port Map (A=> adder_to_npc, B=> PC_in, SEL=> jump_taken_n, OUTPUT=> pc_mux_to_pc);
PC : register_generic Port Map (D=> pc_mux_to_pc, Q=> pc_to_iram, CLK=> CLK, RST=> RST, EN=> fetch_active);
pc_adder : adder Port Map (A=> stall_mux_to_adder, B=> pc_to_iram, S=> adder_to_npc);

npc : register_generic Port Map (D=> adder_to_npc, Q=> NPC_out, CLK=> CLK, RST=> internal_reset, EN=> fetch_active);
ir : register_generic  Port Map (D=> instruction_word_in, Q=> IR_out, CLK=> CLK, RST=> internal_reset, EN=> fetch_active);
end struct;
