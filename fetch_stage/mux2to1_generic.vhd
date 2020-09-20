library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2to1_generic is
    Generic (NBIT : integer := 32);
    Port (A, B : in std_logic_vector(0 to NBIT-1);
          SEL : in std_logic;
          OUTPUT : out std_logic_vector(0 to NBIT-1));
end mux2to1_generic;

architecture rtl of mux2to1_generic is
begin

MuxProc:process(A, B, SEL)
begin
    if(SEL='1') then
        OUTPUT <= A;
    else
        OUTPUT <= B;
    end if;
end process MuxProc;
end rtl;
