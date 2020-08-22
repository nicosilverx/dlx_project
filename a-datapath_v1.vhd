library ieee;
use ieee.std_logic_1164.all;
use WORK.constants.all;
use WORK.alu_types.all;


entity datapath is
	port (ALU_FUNC : IN TYPE_OP;
		  S1, S2 : IN std_logic;
		  IMM1, IMM2, A, B : IN std_logic_vector(0 to NUMBIT-1);
		  OUT1 : OUT std_logic_vector(0 to NUMBIT-1);
		  RST, CLK : IN std_logic);
end datapath;

architecture datapath_rt of datapath is

component mux21 is
  	port (A:    in	std_logic_vector(0 to NUMBIT-1) ;
	      B:	in	std_logic_vector(0 to NUMBIT-1);
          SEL:	in	std_logic;
          Y:	out	std_logic_vector(0 to NUMBIT-1));
end component;

component simple_alu is
	port (	FUNC : IN TYPE_OP;
			INPUT1, INPUT2 : IN std_logic_vector(0 to NUMBIT-1);
			ALU_OUT : OUT std_logic_vector(0 to NUMBIT-1));
end component;

signal current_OP1, current_OP2, current_OUT, next_OP1, next_OP2, next_OUT : std_logic_vector(0 to NUMBIT-1);	--ALU
signal current_A, current_B, current_imm1, current_imm2, next_A, next_B, next_imm1, next_imm2: std_logic_vector(0 to NUMBIT-1);	--MUXs

begin

ALU_1 : simple_alu Port Map (FUNC=> ALU_FUNC, INPUT1=> current_OP1, INPUT2=> current_OP2, ALU_OUT=> next_OUT);
MUX_op1 : mux21 Port Map (A=>current_imm1, B=> current_A, SEL=> S1, Y=> next_OP1);
MUX_op2 : mux21 Port Map (A=>current_B, B=> current_imm2, SEL=> S2, Y=> next_OP2);

--CombLog:process(IMM1, IMM2, A, B, S1, S2, ALU_FUNC, current_OUT, current_OP1, current_OP2, current_imm1, current_imm2, current_A, current_B, CLK,
--		next_OP1, next_OP2, next_A, next_B, next_imm1, next_imm2)
--begin
--	next_imm1 <= IMM1;
--	next_imm2 <= IMM2;
--	next_A <= A;
--	next_B <= B;
--	OUT1 <= current_OUT;
--end process CombLog;
next_imm1 <= IMM1; next_imm2 <= IMM2; next_A <= A; next_B <= B;
OUT1 <= current_OUT;

ClkProc:process(RST, CLK)
begin
	if(RST='0') then
		current_imm1<= (OTHERS=>'0');
		current_imm2<= (OTHERS=>'0');
		current_A	<= (OTHERS=>'0');
		current_B	<= (OTHERS=>'0');
		current_OP1 <= (OTHERS=>'0');
		current_OP2 <= (OTHERS=>'0');
		current_OUT <= (OTHERS=>'0');
	elsif(CLK='1' and CLK'event) then
		current_imm1<= next_imm1;
		current_imm2<= next_imm2;
		current_A	<= next_A;
		current_B	<= next_B;
		current_OP1 <= next_OP1;
		current_OP2 <= next_OP2;
		current_OUT <= next_OUT;	
	end if;
end process ClkProc;

end datapath_rt;