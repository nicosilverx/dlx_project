library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dram_tb is
end dram_tb;

architecture test of dram_tb is

signal ADDR_s, DATAIN_s :  std_logic_vector(0 to 31);
signal DOUT_s :  std_logic_vector(0 to 31);
signal RST_s, READ_s, WRITE_s :  std_logic;
          
component dram is
    Generic (RAM_DEPTH : integer := 48;
             D_SIZE : integer := 32);
    Port (ADDR, DATAIN : in std_logic_vector(0 to D_SIZE-1);
          DOUT : out std_logic_vector(0 to D_SIZE-1);
          RST, READ, WRITE : in std_logic);             
end component;

begin

dut: dram Generic Map (RAM_DEPTH=> 48, D_SIZE=> 32)
    Port Map (ADDR=> ADDR_s, DATAIN=> DATAIN_s, DOUT=> DOUT_s, RST=> RST_s, READ=> READ_s, WRITE=> WRITE_s);

VectProc:process
begin
    ADDR_s<=X"00000000"; DATAIN_s<=X"ffffffff"; RST_s<='0'; READ_s<='0'; WRITE_s<='0';
    wait for 1 ns;
    RST_s<='1';
    wait for 1 ns;
    WRITE_s<='1';
    wait for 1 ns;
    WRITE_s<='0'; READ_s<='1';
    wait for 1 ns;
    wait;
end process VectProc;
end test;
