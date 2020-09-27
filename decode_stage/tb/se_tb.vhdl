library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity se_tb is
end se_tb;

architecture test of se_tb is

signal A_s : std_logic_vector(0 to 15);
signal O_s : std_logic_vector(0 to 31);

component sign_extender_generic is
    Generic (NBIT_input: integer := 16;
             NBIT_output: integer := 32);
    Port (A : in std_logic_vector(0 to NBIT_input-1);
          O : out std_logic_vector(0 to NBIT_output-1));
end component;

begin

dut: sign_extender_generic Generic Map (NBIT_input=>16, NBIT_output=>32) 
	Port Map (A=> A_s, O=> O_s);
VectProc:process
begin
	A_s<=X"FFCE";
	wait for 5 ns;
	assert O_s = X"FFFFFFCE" report "error 1";

	A_s<=X"0032";
	wait for 5 ns;
	assert O_s = X"00000032" report "error 2";
	wait;
end process VectProc;
end test;