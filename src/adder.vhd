library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity adder is
    Port (A, B : in std_logic_vector(0 to 31);
          S    : out std_logic_vector(0 to 31));
end adder;

architecture rtl of adder is
begin
    S <= std_logic_vector(signed(A) + signed(B));
end rtl;
