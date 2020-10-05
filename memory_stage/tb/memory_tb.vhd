library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity memory_tb is
end memory_tb;

architecture test of memory_tb is
--Signals
signal NPC_in_s, ALU_output_s, B_in_s : std_logic_vector(0 to 31);
signal C_in_s : std_logic_vector(0 to 4);
signal is_zero_s, CLK_s, RST_s, EN_READ_s, EN_WRITE_s, EN_LMD_reg_s, EN_ALU_output_reg_s, EN_C_reg_s : std_logic := '1';
signal NPC_out_s, LMD_out_s, ALU_reg_out_s : std_logic_vector(0 to 31);
signal C_out_s : std_logic_vector(0 to 4);
--Component
component memory_stage is
    Generic (NBIT : integer := 32);
    Port (NPC_in, ALU_output, B_in : in std_logic_vector(0 to NBIT-1);
          C_in : in std_logic_vector(0 to 4);
          is_zero, CLK, RST, EN_READ, EN_WRITE, EN_LMD_reg, EN_ALU_output_reg, EN_C_reg : in std_logic;
          NPC_out, LMD_out, ALU_reg_out : out std_logic_vector(0 to NBIT-1);
          C_out : out std_logic_vector(0 to 4));
end component;

begin

DUT: memory_stage Generic Map (NBIT=> 32) Port Map
    (NPC_in=> NPC_in_s, ALU_output=> ALU_output_s, B_in=> B_in_s,
     C_in=> C_in_s,
     is_zero=> is_zero_s, CLK=> CLK_s, RST=> RST_s, EN_READ=> EN_READ_s, EN_WRITE=> EN_WRITE_s, 
     EN_LMD_reg=> EN_LMD_reg_s, EN_ALU_output_reg=> EN_ALU_output_reg_s, EN_C_reg=> EN_C_reg_s, 
     NPC_out=> NPC_out_s, LMD_out=> LMD_out_s, ALU_reg_out=> ALU_reg_out_s,
     C_out=> C_out_s);

ClkProc:process(CLK_s)
begin
    CLK_s<=NOT(CLK_s) after 0.5 ns;
end process ClkProc;

VectProc:process
begin
    NPC_in_s<=X"00000010"; ALU_output_s<=X"00000001"; B_in_s<=X"0000aaaa"; C_in_s<="00011";
    is_zero_s<='1';--Select the NPC_in
    RST_s<='0'; EN_READ_s<='0'; EN_WRITE_s<='0'; EN_LMD_reg_s<='1'; EN_ALU_output_reg_s<='1'; EN_C_reg_s<='1';
    
    wait until CLK_s='1' AND CLK_s'EVENT;
    RST_s<='1';
    EN_WRITE_s<='1';
    wait until CLK_s='1' AND CLK_s'EVENT;
    EN_READ_s<='1'; EN_WRITE_s<='0';
    wait until CLK_s='1' AND CLK_s'EVENT;
    is_zero_s<='0'; --Select the ALU_output as the next PC
    wait;
end process VectProc;
end test;
