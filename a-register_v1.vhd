library ieee;

use ieee.std_logic_1164.all;
use WORK.constants.all;

entity register_32 is
	Port (D : in std_logic_vector(0 to NUMBIT-1);
		  Q : out std_logic_vector(0 to NUMBIT-1);
		  CLK, RST: in std_logic);
end register_32;

architecture register_32_rt of register_32 is
begin
	ClkProc:process(CLK, RST)
	begin
		if (RST='0') then
			Q <= (OTHERS=>'0');
		elsif (CLK='1' AND CLK'EVENT) then
			Q <= D;
		end if;
	end process ClkProc;
end register_32_rt;