library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity adder_generic is
    Generic (NBIT : integer := 32);
    Port (A, B : in std_logic_vector(0 to NBIT-1);
          S    : out std_logic_vector(0 to NBIT-1));
end adder_generic;

architecture rtl of adder_generic is


begin

AddProc:process(A, B)
begin
    S <= std_logic_vector(unsigned(A) + unsigned(B));
end process AddProc;

end rtl;
