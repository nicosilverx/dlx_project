library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity comparator_generic is
    Generic (NBIT: integer := 32);
    Port (A, B : in std_logic_vector(0 to NBIT-1);
          EN : in std_logic;
          EQ, GT, LT : out std_logic);
end comparator_generic;

architecture rtl of comparator_generic is
begin

CompProc:process(A, B, EN)
begin
    if(EN='1') then
        if(A=B) then
            EQ <= '1'; GT<='0'; LT<='0';
        elsif(A>B) then
            EQ <= '0'; GT<='1'; LT<='0';
        else
            EQ <= '0'; GT<='0'; LT<='1';
        end if;
    else
        EQ <= '1'; GT<='1'; LT<='1'; --In this way, if the comparator is not active, meaning that the instruxtion is not
                                    -- a branch instruction, the NPC will be the PC+4 all the times                
    end if;
end process;

end rtl;
