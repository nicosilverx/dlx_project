library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux4to1 is
    Port (A, B, C, D : in std_logic_vector(0 to 31);
          SEL : in std_logic_vector(0 to 1);
          OUTPUT : out std_logic_vector(0 to 31));
end mux4to1;

architecture beh of mux4to1 is

begin
MuxProc:process(A, B, C, D, SEL)
begin
    if(SEL="00")then
        OUTPUT<=D;
    elsif(SEL="01")then
        OUTPUT<=C;
    elsif(SEL="10")then
        OUTPUT<=B;
    else
        OUTPUT<=A;
    end if;
end process MuxProc;
end beh;
