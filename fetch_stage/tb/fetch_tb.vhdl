library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fetch_tb is
end fetch_tb;

architecture test of fetch_tb is
--Signals
signal next_pc_s, IR_out_s, PC_new_s : std_logic_vector(0 to 31);
signal SEL_MUX1_s, PC_EN_s, IR_EN_s, CLK_s, RST_s : std_logic := '1';
--Component under test
component fetch_stage_wrapper is
    Generic (NBIT : integer := 32);
    Port( next_pc: in std_logic_vector(0 to NBIT-1);
          SEL_MUX1, PC_EN, IR_EN, CLK, RST: in std_logic;
          IR_out, PC_new : out std_logic_vector(0 to NBIT-1));
end component;

begin
--DUT instance
fetch_stage_dut : fetch_stage_wrapper Generic Map (NBIT=> 32) Port Map (next_pc=> next_pc_s,
	SEL_MUX1=> SEL_MUX1_s, PC_EN=> PC_EN_s, IR_EN=> IR_EN_s, CLK=> CLK_s, RST=> RST_s,
	IR_out=> IR_out_s, PC_new=> PC_new_s);


ClkProc:process(CLK_s)
begin
	CLK_s<=NOT(CLK_s) after 0.5 ns;
end process ClkProc;


VectProc:process
begin
	next_pc_s<=X"00000000"; SEL_MUX1_s<='0'; PC_EN_s<='1'; IR_EN_s<='1'; RST_s<='0';
	wait until CLK_s='1' AND CLK_s'EVENT;
	RST_s<='1';
	wait until CLK_s='1' AND CLK_s'EVENT;
	wait until CLK_s='1' AND CLK_s'EVENT;
	wait until CLK_s='1' AND CLK_s'EVENT;
	wait;
end process VectProc;
end test;