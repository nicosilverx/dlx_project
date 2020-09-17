library ieee;

use ieee.std_logic_1164.all;
use WORK.constants.all;

entity register_file_tb is
end register_file_tb;

architecture register_file_tb_test of register_file_tb is

signal CLK_s, RST_s, EN_s, RD1_s, RD2_s, WR_s : std_logic := '0';
signal ADD_WR_s, ADD_RD1_s, ADD_RD2_s : std_logic_vector(0 to ADDRBIT-1);
signal DATAIN_s, OUT1_s, OUT2_s : std_logic_vector(0 to NUMBIT-1);

component register_file is
	Port (CLK, RST, EN, RD1, RD2, WR: in std_logic;
		  ADD_WR, ADD_RD1, ADD_RD2  : in std_logic_vector(0 to ADDRBIT-1);
		  DATAIN : in std_logic_vector(0 to NUMBIT-1);
		  OUT1, OUT2 : out std_logic_vector(0 to NUMBIT-1));
end component;

begin

DUT : register_file Port Map (CLK=> CLK_s, RST=> RST_s, EN=> EN_s, RD1=> RD1_s,
	RD2=> RD2_s, WR=> WR_S, ADD_WR=> ADD_WR_s, ADD_RD1=> ADD_RD1_s,
	ADD_RD2=> ADD_RD2_s, DATAIN=> DATAIN_s, OUT1=> OUT1_s, OUT2=> OUT2_s);

ClkProc:process(CLK_s)
begin
	CLK_s<= not(CLK_s) after 0.5 ns;
end process ClkProc;

VectProc:process
begin
	RST_s <= '1','0' after 5 ns;
	EN_s <= '0','1' after 3 ns, '0' after 10 ns, '1' after 15 ns;
	WR_s <= '0','1' after 6 ns, '0' after 7 ns, '1' after 10 ns, '0' after 20 ns;
	RD1_s <= '1','0' after 5 ns, '1' after 13 ns, '0' after 20 ns; 
	RD2_s <= '0','1' after 17 ns;
	ADD_WR_s <= "10110", "01000" after 9 ns;
	ADD_RD1_s <="10110", "01000" after 9 ns;
	ADD_RD2_s<= "11100", "01000" after 9 ns;
	DATAIN_s<=(others => '0'),(others => '1') after 8 ns;

	wait;
end process VectProc;
end register_file_tb_test;