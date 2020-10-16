----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.10.2020 16:57:21
-- Design Name: 
-- Module Name: hazard_register - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hazard_register is
    Port (D: in std_logic_vector(0 to 31);
          Q: out std_logic_vector(0 to 31);
          CLK, RST, EN : in std_logic);
end hazard_register;

architecture rtl of hazard_register is

begin
RegProc:process(CLK, RST, EN)
begin
    if(RST='0') then
        Q <= X"54000000";
    elsif(CLK='1' AND CLK'EVENT) then
        if(EN='1') then
            Q <= D;
        end if;
    end if;
end process RegProc;

end rtl;
