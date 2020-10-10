library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity zero_comparator_generic is
    Generic (NBIT : integer := 32);
    Port (A, B: in std_logic_vector(0 to NBIT-1);
          EN, type_of_comp : in std_logic;
          output: out std_logic);
end zero_comparator_generic;

architecture rtl of zero_comparator_generic is

begin

CompProc:process(A, B, EN, type_of_comp)
begin
    if(EN='1') then
        if(type_of_comp='0') then
            --Branch if A_reg==B_reg
            if(A=B) then
                output <= '1';
            else 
                output <= '0';
            end if;                
        else
            --Branch if A_reg!=B_reg
            if(A/=B) then
                output <= '1';
            else
                output <= '0';
            end if;
        end if;
    else
        output <= '1'; --If disabled, always select PC+4
    end if;
end process CompProc;

end rtl;
