library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity register_generic is
    Generic (NBIT : integer := 32);
    Port (D: in std_logic_vector(0 to NBIT-1);
          Q: out std_logic_vector(0 to NBIT-1);
          CLK, RST, EN : in std_logic);
end register_generic;

architecture rtl of register_generic is
begin

RegProc:process(CLK, RST, EN)
begin
    if(RST='0') then
        Q <= (OTHERS=>'0');
    elsif(CLK='1' AND CLK'EVENT) then
        if(EN='1') then
            Q <= D;
        end if;
    end if;
end process RegProc;

end rtl;
