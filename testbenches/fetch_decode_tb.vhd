library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fetch_decode_tb is
end fetch_decode_tb;

architecture test of fetch_decode_tb is
--Signals
signal PC_in_s, DATA_WR_s :  std_logic_vector(0 to 31);
signal ADD_WR_s :  std_logic_vector(0 to 4);
signal CLK_s, RST_s, PC_EN_s, NPC_EN_s, IR_EN_s, EN_READ1_s, EN_READ2_s, EN_WRITE_s, EN_RF_s, EN_A_s,
    EN_B_s, EN_C_s, EN_IMM_s, EN_NPC_s, sel_imm_mux_s :  std_logic := '0';
signal NPC_out_s, A_out_s, B_out_s, IMM_out_s :  std_logic_vector(0 to 31);
signal C_out_s :  std_logic_vector(0 to 4);
signal Opcode_out_s :  std_logic_vector(0 to 5);
signal Func_out_s   :  std_logic_vector(0 to 10);
--Component
component fetch_decode_wrapper is
    Generic (NBIT : integer := 32);
    Port (PC_in, DATA_WR : in std_logic_vector(0 to NBIT-1);
          ADD_WR : in std_logic_vector(0 to 4);
          CLK, RST, PC_EN, NPC_EN, IR_EN, EN_READ1, EN_READ2, EN_WRITE, EN_RF, EN_A, EN_B, EN_C, EN_IMM, EN_NPC, sel_imm_mux : in std_logic;
          NPC_out, A_out, B_out, IMM_out : out std_logic_vector(0 to NBIT-1);
          C_out : out std_logic_vector(0 to 4);
          Opcode_out : out std_logic_vector(0 to 5);
          Func_out   : out std_logic_vector(0 to 10));
end component;

begin

DUT: fetch_decode_wrapper Generic Map (NBIT=> 32)
    Port Map (PC_in=> PC_in_s, DATA_WR=> DATA_WR_s, 
              ADD_WR=> ADD_WR_s,
              CLK=> CLK_s, RST=> RST_s, PC_EN=> PC_EN_s, NPC_EN=> NPC_EN_s, IR_EN=> IR_EN_s, EN_READ1=>EN_READ1_s, EN_READ2=> EN_READ2_s,
              EN_WRITE=> EN_WRITE_s, EN_RF=> EN_RF_s, EN_A=> EN_A_s, EN_B=> EN_B_s, EN_C=> EN_C_s, EN_IMM=> EN_IMM_s, EN_NPC=> EN_NPC_s, sel_imm_mux=> sel_imm_mux_s,
              NPC_out=> NPC_out_s, A_out=> A_out_s, B_out=> B_out_s, IMM_out=> IMM_out_s,
              C_out=> C_out_s, Opcode_out=> Opcode_out_s, Func_out=> Func_out_s);
              
ClkProc:process(CLK_s)
begin
    CLK_s<=NOT(CLK_s) after 0.5 ns;
end process ClkProc;              

VectProc:process
begin
    PC_in_s<=X"0000001c"; DATA_WR_s<=X"ffffffff"; ADD_WR_s<="00011"; 
    EN_READ1_s<='0'; EN_READ2_s<='0'; EN_WRITE_s<='0';
    RST_s<='0';
    wait until CLK_s='1' and CLK_s'EVENT;
    RST_s<='1'; 
    PC_EN_s<='1'; IR_EN_s<='1'; NPC_EN_s<='1'; 
    
    wait until CLK_s='1' and CLK_s'EVENT;
    PC_EN_s<='0'; IR_EN_s<='0'; NPC_EN_s<='0';
    EN_NPC_s<='1'; EN_READ1_s<='1'; EN_READ2_s<='1'; EN_WRITE_s<='0'; EN_RF_s<='1';
    sel_imm_mux_s<='0';
    EN_A_s<='1'; EN_B_s<='1'; EN_C_s<='1'; EN_IMM_s<='1';
    wait until CLK_s='1' and CLK_s'EVENT;
    PC_EN_s<='0'; IR_EN_s<='0'; NPC_EN_s<='0';
    EN_NPC_s<='0'; EN_READ1_s<='0'; EN_READ2_s<='0'; EN_WRITE_s<='0'; EN_RF_s<='0';
    sel_imm_mux_s<='0';
    EN_A_s<='0'; EN_B_s<='0'; EN_C_s<='0'; EN_IMM_s<='0';
    wait;
end process VectProc;

end test;
