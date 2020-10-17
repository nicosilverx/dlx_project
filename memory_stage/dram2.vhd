library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity dram2 is
    port (
    clock   : in  std_logic;
    rst     : in  std_logic;
    we      : in  std_logic;
    re      : in  std_logic;
    address : in  std_logic_vector;
    datain  : in  std_logic_vector;
    dataout : out std_logic_vector
  );
end dram2;

architecture rtl of dram2 is
   type ram_type is array (0 to 48) of std_logic_vector(datain'range);
   signal ram : ram_type;
   signal read_address : std_logic_vector(address'range) := (OTHERS=>'0');
begin
RamProc: process(clock) is

  begin
    if(rst='0') then
        for index in 0 to 48 loop
            ram(index) <= (OTHERS=>'0');
        end loop;
    elsif rising_edge(clock) then
      if we = '1' then
        ram(to_integer(unsigned(address))) <= datain;
      elsif re = '1' then
      read_address <= address;
      end if;
    end if;
  end process RamProc;

  dataout <= ram(to_integer(unsigned(read_address)));

end rtl;
