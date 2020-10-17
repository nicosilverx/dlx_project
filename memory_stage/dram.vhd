library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity dram is
    Port (ADDRESS, DATAIN : in std_logic_vector(0 to 31);
          CLK, RST, WE, RE : in std_logic;
          DATAOUT : out std_logic_vector(0 to 31));
end dram;

architecture beh of dram is
   type ram_type is array (0 to 48) of std_logic_vector(0 to 31);
   signal ram : ram_type;
   signal read_address : std_logic_vector(0 to 31) := (OTHERS=>'0');
begin

--dataout <= ram(to_integer(unsigned(read_address)));

RamProc:process(ADDRESS, DATAIN, RST, WE, RE, CLK)
begin
    if(re='1')then
        dataout <= ram(to_integer(unsigned(address)));
    end if;
    if(RST='0') then
        for index in 0 to 48 loop
            ram(index) <= (OTHERS=>'0');
        end loop;
    elsif(CLK='1' AND CLK'EVENT) then
        if we = '1' then
            ram(to_integer(unsigned(address))) <= datain;
        elsif re = '1' then
            --dataout <= ram(to_integer(unsigned(address)));
        end if;
    end if;
end process RamProc;
end beh;