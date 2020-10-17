library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity register_file is
    Generic (N_ROWS       : integer := 32;
             NBIT_ADDRESS : integer := 5;
             NBIT_WORD    : integer := 32);
	Port (CLK, RST, EN, RD1, RD2, WR: in std_logic;
		  ADD_WR, ADD_RD1, ADD_RD2  : in std_logic_vector(0 to NBIT_ADDRESS-1);
		  DATAIN : in std_logic_vector(0 to NBIT_WORD-1);
		  OUT1, OUT2 : out std_logic_vector(0 to NBIT_WORD-1));
end register_file;

architecture beh of register_file is

subtype RF_ADDR is natural range 0 to N_ROWS-1;
type RF_ARRAY is array(RF_ADDR) of std_logic_vector(0 to NBIT_WORD-1);
signal RF : RF_ARRAY;

begin

RFProc:process(RST, EN, RD1, RD2, WR, ADD_WR, ADD_RD1, ADD_RD2, DATAIN)
variable ctrl_sig : std_logic_vector(0 to 2);
begin
    RF(0) <= (OTHERS=>'0'); --R0 always at 0
	ctrl_sig := (WR & RD1 & RD2);
    if (RST='0') then
    	RF <= (OTHERS=>(OTHERS=>'0'));
        OUT1 <= (OTHERS=>'0');
        OUT2 <= (OTHERS=>'0');
    --elsif (CLK='1' AND CLK'EVENT AND EN='1') then
    elsif (EN='1') then
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
end process RFProc;

end beh;
