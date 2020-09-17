library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use WORK.constants.all;

entity register_file is
	Port (CLK, RST, EN, RD1, RD2, WR: in std_logic;
		  ADD_WR, ADD_RD1, ADD_RD2  : in std_logic_vector(0 to ADDRBIT-1);
		  DATAIN : in std_logic_vector(0 to NUMBIT-1);
		  OUT1, OUT2 : out std_logic_vector(0 to NUMBIT-1));
end register_file;

architecture register_file_rt of register_file is

subtype RF_ADDR is natural range 0 to NUMRF-1;
type RF_ARRAY is array(RF_ADDR) of std_logic_vector(0 to NUMBIT-1);
signal RF : RF_ARRAY;

begin

ClkProc:process(CLK, RST)
variable ctrl_sig : std_logic_vector(0 to 2);
begin
	ctrl_sig := (WR & RD1 & RD2);
    if (RST='0') then
    	RF <= (OTHERS=>(OTHERS=>'0'));
        OUT1 <= (OTHERS=>'0');
        OUT2 <= (OTHERS=>'0');
    elsif (CLK='1' AND CLK'EVENT AND EN='1') then
    	case ctrl_sig is
                when "000" => OUT1 <= (OTHERS=>'0'); OUT2 <= (OTHERS=>'0');
                when "001" => OUT1 <= (OTHERS=>'0'); OUT2 <= RF(to_integer(unsigned(ADD_RD2)));
                when "010" => OUT1 <= RF(to_integer(unsigned(ADD_RD1))); OUT2 <= (OTHERS=>'0');
                when "011" => OUT1 <= RF(to_integer(unsigned(ADD_RD1))); OUT2 <= RF(to_integer(unsigned(ADD_RD2)));
                when "100" => RF(to_integer(unsigned(ADD_WR))) <= DATAIN; OUT1 <= (OTHERS=>'0'); OUT2 <= (OTHERS=>'0'); 
                when "101" => RF(to_integer(unsigned(ADD_WR))) <= DATAIN; OUT1 <= (OTHERS=>'0'); OUT2 <= RF(to_integer(unsigned(ADD_RD2)));
                when "110" => RF(to_integer(unsigned(ADD_WR))) <= DATAIN; OUT1 <= RF(to_integer(unsigned(ADD_RD1))); OUT2 <= (OTHERS=>'0');
                when "111" => RF(to_integer(unsigned(ADD_WR))) <= DATAIN; OUT1 <= RF(to_integer(unsigned(ADD_RD1))); OUT2 <= RF(to_integer(unsigned(ADD_RD2)));
                when others=> OUT1 <= (OTHERS=>'0'); OUT2 <= (OTHERS=>'0');
            end case;
    end if;
end process ClkProc;
end register_file_rt;