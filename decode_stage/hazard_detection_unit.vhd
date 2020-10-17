library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hazard_detection_unit is
    Port (Rs1, Rs2, Rt, Rt_EX, Rt_MEM: in std_logic_vector(0 to 4);
          Opcode : in std_logic_vector(0 to 5);
          Next_opcode : in std_logic_vector(0 to 5);
          CLK, M_EN_READ: in std_logic;
          STALL : out std_logic);
end hazard_detection_unit;

architecture beh of hazard_detection_unit is
signal STALL_v : std_logic := '0';
signal stall_counter : integer := 0;
begin

hazProc:process(Rs1, Rs2, Rt, Rt_EX, M_EN_READ, STALL_v)
begin
    if(Opcode="000000") then
        if(M_EN_READ='1' and (Rt_EX=Rs1 OR RT_EX=Rs2 OR Rt_MEM=Rs1 OR Rt_MEM=Rs2)) then
            STALL_v<='1';
        else
            STALL_v<='0';
        end if;
    elsif(Opcode="001000" OR Opcode="001010" OR Opcode="001100" OR Opcode="001101" OR
          Opcode="001110" OR Opcode="010100" OR Opcode="010110" OR Opcode="011001" OR Opcode="011100" OR Opcode="011101") then
          if(M_EN_READ='1' and (Rt_EX=Rs1 OR Rt_MEM=Rs1)) then
           STALL_v<='1';
          else
            STALL_v<='0';
          end if; 
    elsif(Opcode="101011") then --sw
        if(((Rt_EX=Rs1 OR RT_EX=Rs2 OR Rt_MEM=Rs1 OR Rt_MEM=Rs2) AND (Opcode/=Next_opcode)) OR (Next_opcode="100011")) then
            STALL_v<='1';
        else
            STALL_v<='0';
        end if;   
    elsif(Opcode="100011")then
        if((Rt_EX=Rs1 OR RT_EX=Rs2 OR Rt_MEM=Rs1 OR Rt_MEM=Rs2) AND Opcode/=Next_opcode) then
            STALL_v<='1';
        else
            STALL_v<='0';
        end if; 
    elsif(Opcode="000100" OR Opcode="000101" )then
        if(Rs1=Rt_EX OR Rs1=Rt_MEM)then
            STALL_v<='1';
        else
            STALL_v<='0';
        end if;
    else
        STALL_v<='0';
    end if;
end process;

stallcount:process(CLK, STALL_v, stall_counter)
begin
    if(CLK='0' AND CLK'EVENT)then
        if(STALL_v='1')then
            STALL <= '1';
            stall_counter <= 2;
        end if;
        
        if(stall_counter > 0 ) then
            STALL <= '1';
            stall_counter <= stall_counter - 1;
        elsif(stall_counter=0 and STALL_v='0')then
            STALL <= '0';
        end if;
    end if;
end process stallcount;

end beh;
