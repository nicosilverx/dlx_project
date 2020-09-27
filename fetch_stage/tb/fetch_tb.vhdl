library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fetch_tb is
end fetch_tb;

architecture test of fetch_tb is
--Signals
signal PC_in_s, IR_out_s, NPC_out_s : std_logic_vector(0 to 31);
signal NPC_EN_S, PC_EN_s, IR_EN_s, CLK_s, RST_s : std_logic := '1';
--Component under test
component fetch_stage_wrapper is
    Generic (NBIT : integer := 32);
    Port(PC_in : in std_logic_vector(0 to NBIT-1);
         NPC_out, IR_out : out std_logic_vector(0 to NBIT-1);
         CLK, RST, PC_EN, NPC_EN, IR_EN : in std_logic);
end component;

begin
--DUT instance
fetch_stage_dut : fetch_stage_wrapper Generic Map (NBIT=> 32) Port Map (PC_in=> PC_in_s,
	NPC_out=> NPC_out_s, IR_out=> IR_out_s, CLK=> CLK_s, RST=> RST_s, PC_EN=> PC_EN_s,
	NPC_EN=> NPC_EN_S, IR_EN=> IR_EN_s);


ClkProc:process(CLK_s)
begin
	CLK_s<=NOT(CLK_s) after 0.5 ns;
end process ClkProc;


VectProc:process
begin
	PC_in_s<=X"00000000"; RST_s<='0'; PC_EN_s<='1'; NPC_EN_S<='1'; IR_EN_s<= '1';
	wait until CLK_s='1' AND CLK_s'EVENT;
	RST_s<='1'; 
	wait until CLK_s='1' AND CLK_s'EVENT;
	PC_in_s <= X"00000004";
	wait until CLK_s='1' AND CLK_s'EVENT;
	PC_in_s <= X"00000008";
	wait until CLK_s='1' AND CLK_s'EVENT;
	PC_in_s <= X"0000000C";
	wait;
end process VectProc;
end test;