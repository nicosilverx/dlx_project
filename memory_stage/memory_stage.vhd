library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity memory_stage is
    Port(ALU_in, DRAM_in : in std_logic_vector(0 to 31);
         C_in : in std_logic_vector(0 to 4);
         is_link, memory_active, flush, RST, CLK : in std_logic;
         LMD_out, ALU_out: out std_logic_vector(0 to 31);
         C_out : out std_logic_vector(0 to 4));
end memory_stage;

architecture struct of memory_stage is
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
--Wires
signal c_mux_out : std_logic_vector(0 to 4) := (OTHERS=>'0');
signal internal_reset : std_logic := '1';

begin
internal_reset <= RST AND NOT(flush);

--C mux
c_mux : mux2to1 Generic Map (NBIT=> 5) Port Map (A=> "11111", B=> C_in, SEL=> is_link, OUTPUT=> c_mux_out);
--LMD reg
LMD : register_generic Port Map (D=> DRAM_in, Q=> LMD_out, CLK=> CLK, RST=> internal_reset, EN=> memory_active);
--ALU reg
alu_reg : register_generic Port Map (D=> ALU_in, Q=> ALU_out, CLK=> CLK, RST=> internal_reset, EN=> memory_active);
--C reg
c_reg : register_generic Generic Map (NBIT=> 5) Port Map (D=> c_mux_out, Q=> C_out, CLK=> CLK, RST=> internal_reset, EN=> memory_active);

end struct;
