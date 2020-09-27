library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decode_tb is
end decode_tb;

architecture test of decode_tb is
--Signals
signal IR_in_s, PC_in_s :  std_logic_vector(0 to 31);
signal RF_EN_s, READ1_EN_s, READ2_EN_s, WRITE_EN_s, RS1_EN_s, RS2_EN_s, RS_EN_s, RD_EN_s, IMM_EN_s, IS_BRANCH_s, CLK_s, RST_s : std_logic := '0';
signal RD_address_s :  std_logic_vector(0 to 4);
signal RD_data_s    :  std_logic_vector(0 to 31);
signal RS1_out_s, RS2_out_s, IMM_out_s, PC_out_s : std_logic_vector(0 to 31);
signal RS_out_s, RD_out_s : std_logic_vector(0 to 4);
signal OPCODE_out_s :  std_logic_vector(0 to 5);
signal FUNC_out_s   :  std_logic_vector(0 to 10);
signal IS_EQUAL_s   :  std_logic;
--Component under test
component decode_stage is
    Generic (NBIT : integer := 32);
    Port (IR_in, PC_in : in std_logic_vector(0 to NBIT-1);
          RF_EN, READ1_EN, READ2_EN, WRITE_EN, RS1_EN, RS2_EN, RS_EN, RD_EN, IMM_EN, IS_BRANCH, CLK, RST : in std_logic;
          RD_address : in std_logic_vector(0 to 4);
          RD_data    : in std_logic_vector(0 to NBIT-1);
          RS1_out, RS2_out, IMM_out, PC_out : out std_logic_vector(0 to NBIT-1);
          RS_out, RD_out : out std_logic_vector(0 to 4);
          OPCODE_out : out std_logic_vector(0 to 5);
          FUNC_out   : out std_logic_vector(0 to 10);
          IS_EQUAL   : out std_logic); 
end component;

begin

decode_dut : decode_stage Generic Map (NBIT=> 32) Port Map (IR_in=> IR_in_s, PC_in=> PC_in_s,
	RF_EN=> RF_EN_s, READ1_EN=> READ1_EN_s, READ2_EN=> READ2_EN_s, WRITE_EN=> WRITE_EN_s, RS1_EN=> RS1_EN_s, RS2_EN=> RS2_EN_s,
	RS_EN=> RS_EN_s, RD_EN=> RD_EN_s, IMM_EN=> IMM_EN_s, IS_BRANCH=> IS_BRANCH_s, CLK=> CLK_s, RST=> RST_s, RD_address=> RD_address_s, 
	RD_data=> RD_data_s, RS1_out=> RS1_out_s, RS2_out=> RS2_out_s, RS_out=> RS_out_s, RD_out=> RD_out_s, IMM_out=> IMM_out_s, PC_out=> PC_out_s,
	OPCODE_out=> OPCODE_out_s, FUNC_out=> FUNC_out_s, IS_EQUAL=> IS_EQUAL_s);

ClkProc:process(CLK_s)
begin
	CLK_s<= NOT(CLK_s) after 0.5 ns;
end process ClkProc;	

VectProc:process
begin
RST_s<='0';
RF_EN_s<='1'; READ1_EN_s<='1'; READ2_EN_s<='1'; RS1_EN_s<='1'; RS2_EN_s<='1'; RS_EN_s<='1'; RD_EN_s<='1'; IMM_EN_s<='1'; IS_BRANCH_s<='0';
RD_address_s<="00000"; RD_data_s<=X"00000000"; 
IR_in_s<=X"1040fff0"; PC_in_s<=X"0000000c";

wait until CLK_s='1' AND CLK_s'EVENT;
RST_s<='1';
wait until CLK_s='1' AND CLK_s'EVENT;

wait;
end process VectProc;
end test;