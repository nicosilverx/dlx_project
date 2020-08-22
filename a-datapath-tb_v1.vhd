library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.alu_types.all;
use WORK.constants.all;

entity datapath_tb is
end entity;

architecture datapath_tb_test of datapath_tb is

signal ALU_FUNC_s : TYPE_OP := ADD;
signal S1_s, S2_s : std_logic;
signal IMM1_s, IMM2_s, A_s, B_s : std_logic_vector(0 to NUMBIT-1);
signal OUT1_s : std_logic_vector(0 to NUMBIT-1);
signal RST_s, CLK_s : std_logic := '0';

component datapath is
	port (ALU_FUNC : IN TYPE_OP;
		  S1, S2 : IN std_logic;
		  IMM1, IMM2, A, B : IN std_logic_vector(0 to NUMBIT-1);
		  OUT1 : OUT std_logic_vector(0 to NUMBIT-1);
		  RST, CLK : IN std_logic);
end component;

begin

	DUT : datapath Port Map (ALU_FUNC=> ALU_FUNC_s, S1=> S1_s, S2=> S2_s, 
		IMM1=> IMM1_s, IMM2=> IMM2_s, A=> A_s, B=> B_s, OUT1=> OUT1_s,
		RST=> RST_s, CLK=> CLK_s);

	ClkProc:process(CLK_s)
	begin
		CLK_s <= NOT(CLK_s) after 5 ns;
	end process ClkProc;

	VectProc:process
	begin
		A_s <= X"00000035"; B_s <= X"00000068"; RST_s<='0';
		IMM1_s <= X"FFFFFFD3"; IMM2_s <= X"000001C8";
		S1_s <= '1'; S2_s <= '0';

		wait until (CLK_s='1' and CLK_s'event);
		RST_s<='1'; ALU_FUNC_s <= ADD;
		
			wait until (CLK_s='1' and CLK_s'event);
			wait for 5 ns;
			assert (OUT1_s=X"0000009D");

			ALU_FUNC_s <= SUB;
			wait until (CLK_s='1' and CLK_s'event);
			wait for 5 ns;
			assert (OUT1_s=X"FFFFFFCD");

			ALU_FUNC_s <= MULT;
			wait until (CLK_s='1' and CLK_s'event);
			wait for 5 ns;
			assert (OUT1_s=X"00001588");

			ALU_FUNC_s <= BITAND;
			wait until (CLK_s='1' and CLK_s'event);
			wait for 5 ns;
			assert (OUT1_s=X"00000020");

			ALU_FUNC_s <= BITOR;
			wait until (CLK_s='1' and CLK_s'event);
			wait for 5 ns;
			assert (OUT1_s=X"0000007D");

			ALU_FUNC_s <= BITXOR;
			B_s <= X"00000005";
			wait until (CLK_s='1' and CLK_s'event);
			wait for 5 ns;
			assert (OUT1_s=X"0000005D");



			ALU_FUNC_s <= FUNCLSL;
			wait until (CLK_s='1' and CLK_s'event);
			wait for 5 ns;
			assert (OUT1_s=X"000006A0") report "FUNCLSL";

			ALU_FUNC_s <= FUNCLSR;
			wait until (CLK_s='1' and CLK_s'event);
			wait for 5 ns;
			assert (OUT1_s=X"00000001") report "FUNCLSR";

			ALU_FUNC_s <= FUNCASL;
			wait until (CLK_s='1' and CLK_s'event);
			wait for 5 ns;
			assert (OUT1_s=X"000006A0");

			ALU_FUNC_s <= FUNCASR;
			wait until (CLK_s='1' and CLK_s'event);
			wait for 5 ns;
			assert (OUT1_s=X"00000001");

			ALU_FUNC_s <= FUNCRL;
			wait until (CLK_s='1' and CLK_s'event);
			wait for 5 ns;
			assert (OUT1_s=X"000006A0");

			ALU_FUNC_s <= FUNCRR;
			wait until (CLK_s='1' and CLK_s'event);
			wait for 5 ns;
			assert (OUT1_s=X"A8000001");

			wait;
	end process VectProc;
end datapath_tb_test;
