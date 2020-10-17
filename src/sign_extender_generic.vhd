library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity sign_extender_generic is
    Generic (NBIT_input: integer := 16;
             NBIT_output: integer := 32);
    Port (A : in std_logic_vector(0 to NBIT_input-1);
          O : out std_logic_vector(0 to NBIT_output-1));
end sign_extender_generic;

architecture beh of sign_extender_generic is

begin

SignProc:process(A)
begin
    O <= std_logic_vector(resize(signed(A),NBIT_output));
end process SignProc;

end beh;
