library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DLX_tb is
end DLX_tb;

architecture test of DLX_tb is
--Signal
signal CLK_s, RST_s : std_logic := '0';
signal datapath_out_s : std_logic_vector(0 to 31);
--DUT
component DLX is
    Port (CLK, RST : in std_logic;
          datapath_out : out std_logic_vector(0 to 31));
end component;
begin

dlx_dut : DLX Port Map (CLK=> CLK_s, RST=> RST_s, datapath_out=> datapath_out_s);

ClkProc:process(CLK_s)
begin
    CLK_s <= NOT(CLK_s) after 0.5 ns;
end process ClkProc;

VectProc:process
begin
    RST_s<='0';
    WAIT UNTIL CLK_s='1' AND CLK_s'EVENT;
    WAIT UNTIL CLK_s='1' AND CLK_s'EVENT;
    wait for 0.1 ns;
    RST_s<='1';
    WAIT UNTIL CLK_s='1' AND CLK_s'EVENT;
    WAIT UNTIL CLK_s='1' AND CLK_s'EVENT;
    WAIT UNTIL CLK_s='1' AND CLK_s'EVENT;
    WAIT UNTIL CLK_s='1' AND CLK_s'EVENT;
    WAIT UNTIL CLK_s='1' AND CLK_s'EVENT;
    WAIT UNTIL CLK_s='1' AND CLK_s'EVENT;
    WAIT UNTIL CLK_s='1' AND CLK_s'EVENT;
    wait;
end process VectProc;
end test;
