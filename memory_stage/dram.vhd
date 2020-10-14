library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity dram is
    Generic (RAM_DEPTH : integer := 48;
             D_SIZE : integer := 32);
    Port (ADDR, DATAIN : in std_logic_vector(0 to D_SIZE-1);
          DOUT : out std_logic_vector(0 to D_SIZE-1);
          RST, READ, WRITE : in std_logic);             
end dram;

architecture rtl of dram is

type RAMtype is array (0 to RAM_DEPTH - 1) of std_logic_vector(0 to D_SIZE-1) ;
signal DRAM_mem : RAMtype;

begin


RamProc:process(RST, READ, WRITE, ADDR, DATAIN)
variable ctrl_sig : std_logic_vector(0 to 1);
begin
 ctrl_sig := READ & WRITE;
 if(RST='0') then
    for index in 0 to RAM_DEPTH-1 loop
        DRAM_mem(index) <= (OTHERS=>'0');
    end loop;
 else
    case ctrl_sig is
        when "00" => DOUT <= (OTHERS=>'0');
        when "01" => DRAM_mem(to_integer(unsigned(ADDR))) <= DATAIN;
        when "10" => DOUT <= DRAM_mem(to_integer(unsigned(ADDR))); 
        when "11" => DOUT <= DRAM_mem(to_integer(unsigned(ADDR))); --Do I need two ports?
        when OTHERS => DOUT <= (OTHERS=>'0');
    end case;
 end if;
end process RamProc;

end rtl;