library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decode_tb is
end decode_tb;

architecture test of decode_tb is
--Signals
signal NPC_in_s, IR_in_s, WB_datain_s :  std_logic_vector(0 to 31);
signal WB_add_s :  std_logic_vector(0 to 4);
signal NPC_out_s, A_out_s, B_out_s, IMM_out_s :  std_logic_vector(0 to 31);
signal C_out_s :  std_logic_vector(0 to 4);
signal Opcode_out_s :  std_logic_vector(0 to 5);
signal Func_out_s   :  std_logic_vector(0 to 10);
signal EN_READ1_s, EN_READ2_s, EN_WRITE_s, EN_RF_s, EN_A_s, EN_B_s, EN_C_s, EN_IMM_s, sel_imm_mux_s, CLK_s, RST_s : std_logic :='1';
--Component under test
component decode_stage is
    Generic (NBIT : integer := 32);
    Port (NPC_in, IR_in, WB_datain : in std_logic_vector(0 to NBIT-1);
          WB_add : in std_logic_vector(0 to 4);
          NPC_out, A_out, B_out, IMM_out : out std_logic_vector(0 to NBIT-1);
          C_out : out std_logic_vector(0 to 4);
          Opcode_out : out std_logic_vector(0 to 5);
          Func_out   : out std_logic_vector(0 to 10);
          EN_READ1, EN_READ2, EN_WRITE, EN_RF, EN_A, EN_B, EN_C, EN_IMM, sel_imm_mux, CLK, RST : in std_logic); 
end component;

begin

decode_dut : decode_stage Generic Map (NBIT=> 32) Port Map (
    NPC_in=> NPC_in_s, IR_in=> IR_in_s, WB_datain=> WB_datain_s,
    WB_add=> WB_add_s,
    NPC_out=> NPC_out_s, A_out=> A_out_s, B_out=> B_out_s, IMM_out=> IMM_out_s,
    C_out=> C_out_s,
    Opcode_out=> Opcode_out_s,
    Func_out=> Func_out_s,
    EN_READ1=> EN_READ1_s, EN_READ2=> EN_READ2_s, EN_WRITE=> EN_WRITE_s, EN_RF=> EN_RF_s, 
    EN_A=> EN_A_s, EN_B=> EN_B_s, EN_C=> EN_C_s, EN_IMM=> EN_IMM_s, sel_imm_mux=> sel_imm_mux_s, CLK=> CLK_s, RST=> RST_s);

ClkProc:process(CLK_s)
begin
	CLK_s<= NOT(CLK_s) after 0.5 ns;
end process ClkProc;	

VectProc:process
begin
RST_s<='0';
EN_RF_s<='1'; EN_READ1_s<='1'; EN_READ2_s<='1'; EN_WRITE_s<='0'; EN_A_s<='1'; EN_B_s<='1'; EN_C_s<='1'; EN_IMM_s<='1'; 
sel_imm_mux_s<='0';
WB_add_s<="00001"; WB_datain_s<=X"FFFFFFFF"; 
IR_in_s<=X"1040fff0"; NPC_in_s<=X"0000000c";

wait until CLK_s='1' AND CLK_s'EVENT;
RST_s<='1';
wait until CLK_s='1' AND CLK_s'EVENT;
EN_WRITE_s<='1'; 
wait until CLK_s='1' AND CLK_s'EVENT;
EN_WRITE_s<='0';
wait until CLK_s='1' AND CLK_s'EVENT;
sel_imm_mux_s<='1';
wait until CLK_s='1' AND CLK_s'EVENT;

wait;
end process VectProc;
end test;