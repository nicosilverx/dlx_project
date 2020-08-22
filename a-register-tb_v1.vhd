library ieee;

use ieee.std_logic_1164.all;
use WORK.constants.all;

entity register_32_tb is
end register_32_tb;

architecture register_32_tb_test of register_32_tb is

signal D_s, Q_s : std_logic_vector(0 to NUMBIT-1);
signal CLK_s : std_logic := '0';
signal RST_s : std_logic;

component register_32 is
	Port (D : in std_logic_vector(0 to NUMBIT-1);
		  Q : out std_logic_vector(0 to NUMBIT-1);
		  CLK, RST: in std_logic);
end component;

begin

DUT : register_32 Port Map (D=>D_s, Q=> Q_s, CLK=> CLK_s, RST=> RST_s);

ClkProc:process(CLK_s)
begin
	CLK_s <= not(CLK_s) after 5 ns;
end process ClkProc;

VectProc:process
begin
	D_s <= X"FFFFFFFF"; RST_s <= '0';
	wait until CLK_s='1' and CLK_s'EVENT;

	RST_s <= '1';
	wait until CLK_s='1' and CLK_s'EVENT;

	D_s <=X"AAAAAAAA";
	wait until CLK_s='1' and CLK_s'EVENT;

	wait;	
end process VectProc;

end register_32_tb_test;