library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity iram is
    Generic (RAM_DEPTH : integer := 48;
             I_SIZE : integer := 32);
    Port (Rst  : in  std_logic;
          Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
          Dout : out std_logic_vector(I_SIZE - 1 downto 0));
end iram;

architecture beh of iram is

type RAMtype is array (0 to RAM_DEPTH - 1) of std_logic_vector(0 to I_SIZE-1);
signal IRAM_mem : RAMtype;

begin

Dout <= IRAM_mem(conv_integer(ieee.std_logic_arith.UNSIGNED(shift_right(ieee.NUMERIC_STD.UNSIGNED(Addr), 2))));

FILL_MEM_P: process (Rst)
    file mem_fp: text;
    variable file_line : line;
    variable index : integer := 0;
    variable tmp_data_u : std_logic_vector(I_SIZE-1 downto 0);
  begin  -- process FILL_MEM_P
    if (Rst = '0') then
      for index in 0 to RAM_DEPTH-1 loop
        IRAM_mem(index) <= (X"54000000");
      end loop;
      file_open(mem_fp,"C:\Users\Nicol�\Desktop\Digital_Designs\git_repositories\dlx_project-dlx_dp2\asm\hazard_test_dump.txt",READ_MODE);
      while (not endfile(mem_fp)) loop
        readline(mem_fp,file_line);
        hread(file_line,tmp_data_u);
        IRAM_mem(index) <= (std_logic_vector(tmp_data_u));       
        index := index + 1;
      end loop;
    end if;
  end process FILL_MEM_P;
  
end beh;