library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register_generic is
    Generic (NBIT : integer := 32;
             EDGE : std_logic := '1';
             RESET_VALUE : std_logic := '0');
    Port (D: in std_logic_vector(0 to NBIT-1);
          Q: out std_logic_vector(0 to NBIT-1);
          CLK, RST, EN : in std_logic);
end register_generic;

architecture beh of register_generic is

begin
RegProc:process(CLK, RST, EN)
begin
    if(CLK=EDGE AND CLK'EVENT) then
        if(RST='0') then
            Q <= (OTHERS=>RESET_VALUE);
        elsif(EN='1') then
            Q <= D;
        end if;
    end if;
end process RegProc;

end beh;
