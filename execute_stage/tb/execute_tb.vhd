library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity execute_tb is
end execute_tb;

architecture test of execute_tb is
--Signals
signal NPC_in_s, A_in_s, B_in_s, Imm_in_s, C_in_s : std_logic_vector(0 to 31);
signal sel_op1_mux_s, sel_op2_mux_s, EN_ALU_output_s, CLK_s, RST_s : std_logic := '1';
signal ALU_func_s : std_logic_vector(0 to 3);
signal NPC_out_s, ALU_output_s, C_out_s : std_logic_vector(0 to 31);
signal is_zero_s : std_logic;
--Component under test
component execute_stage is
    Generic (NBIT : integer := 32);
    Port (NPC_in, A_in, B_in, Imm_in, C_in : in std_logic_vector(0 to NBIT-1);
          sel_op1_mux, sel_op2_mux, EN_ALU_output, CLK, RST : in std_logic;
          ALU_func : in std_logic_vector(0 to 3);
          NPC_out, ALU_output, C_out : out std_logic_vector(0 to NBIT-1);
          is_zero : out std_logic );
end component;

begin

DUT : execute_stage Generic Map (NBIT=> 32) Port Map 
    (NPC_in=> NPC_in_s, A_in=> A_in_s, B_in=> B_in_s, Imm_in=> Imm_in_s, C_in=> C_in_s,
    sel_op1_mux=> sel_op1_mux_s, sel_op2_mux=> sel_op2_mux_s, EN_ALU_output=> EN_ALU_output_s, CLK=> CLK_s, RST=> RST_s,
    ALU_func=> ALU_func_s,
    NPC_out=> NPC_out_s, ALU_output=> ALU_output_s, C_out=> C_out_s,
    is_zero=> is_zero_s);

ClkProc:process(CLK_S)
begin
    CLK_S<=NOT(CLK_S) after 0.5 ns;
end process ClkProc;

VectProc:process
begin
    NPC_in_s <= X"0000000f"; A_in_s<=X"00000001"; B_in_s<=X"00000002"; Imm_in_s<=X"00000003"; C_in_s<=X"0000ffff";
    sel_op1_mux_s <= '1'; sel_op2_mux_s <= '0'; EN_ALU_output_s <= '1'; RST_s<='0'; 
    ALU_func_s <= "0000";
    wait until CLK_s='1' AND CLK_s'EVENT;
    RST_s<='1';
    wait until CLK_s='1' AND CLK_s'EVENT;
    wait;
end process VectProc;
end test;
