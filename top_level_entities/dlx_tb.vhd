library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dlx_tb is
end dlx_tb;

architecture test of dlx_tb is
--DUT
component dlx is
    Port(CLK, RST : in std_logic;
         datapath_out : out std_logic_vector(0 to 31));
end component;

signal CLK_s : std_logic := '0';
signal RST_s : std_logic := '1';
signal datapath_out_s : std_logic_vector(0 to 31) := (OTHERS=>'0');
begin

dlx_dut : dlx Port Map (CLK=> CLK_s, RST=> RST_s, datapath_out=> datapath_out_s);

ClkProc:process(CLK_s)
begin
    CLK_s<=NOT(CLK_s) after 0.5 ns;
end process ClkProc;

VectProc:process
begin
    RST_s<='0';
    wait until CLK_s='1' AND CLK_s'EVENT;
    RST_s<='1';
    wait until CLK_s='1' AND CLK_s'EVENT;
    wait;
end process VectProc;
end test;
