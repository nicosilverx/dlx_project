library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hazard_unit is
    Port (Rs1, Rs2, Rt, Rt_EX: in std_logic_vector(0 to 4);
          Opcode : in std_logic_vector(0 to 5);
          M_EN_READ: in std_logic;
          STALL : out std_logic);
end hazard_unit;

architecture rtl of hazard_unit is
--signal stall_counter : integer := 2;
begin

hazProc:process(Rs1, Rs2, Rt, Rt_EX, M_EN_READ)
variable stall_v, stall_active : std_logic;
variable stall_counter : integer := 0;
begin
    if(Opcode="000000") then
        if(M_EN_READ='1' and (Rt_EX=Rs1 OR RT_EX=Rs2)) then
            STALL<='1';
        else
            STALL<='0';
        end if;
    elsif(Opcode="000100" OR Opcode="000101" OR Opcode="001000" OR Opcode="001010" OR Opcode="001100" OR Opcode="001101" OR
          Opcode="001110" OR Opcode="010100" OR Opcode="010110" OR Opcode="011001" OR Opcode="011100" OR Opcode="011101" OR
          Opcode="101011") then
          if(M_EN_READ='1' and (Rt_EX=Rs1)) then
           STALL<='1';
          else
            STALL<='0';
          end if;
    else
        STALL<='0';
    end if;
    
--    if(stall_v='1')then
--        stall_counter := 0;
--        STALL<='1';
--        stall_active := '1';
--    end if;
    
--    if(CLK='1' AND CLK'EVENT)then
--        if(stall_counter /= 1 and stall_active='1')then
--            stall_counter := stall_counter + 1;
--            STALL<='1';
--        else
--            stall_active:='0';
--            STALL<='0';
--        end if;
--    end if;
end process;

end rtl;
