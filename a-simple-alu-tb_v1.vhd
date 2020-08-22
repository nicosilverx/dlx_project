library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.alu_types.all;
use WORK.constants.all;

entity simple_tb_alu is
end simple_tb_alu;

architecture simple_tb_alu_test of simple_tb_alu is
	
	signal FUNC_s : TYPE_OP := ADD;
	signal INPUT1_s : std_logic_vector(0 to NUMBIT-1);
	signal INPUT2_s : std_logic_vector(0 to NUMBIT-1);
	signal ALU_OUT_s : std_logic_vector(0 to NUMBIT-1);

	component simple_alu is
	port (	FUNC : IN TYPE_OP;
			INPUT1, INPUT2 : IN std_logic_vector(0 to NUMBIT-1);
			ALU_OUT : OUT std_logic_vector(0 to NUMBIT-1));
	end component;

	begin

		DUT : simple_alu Port Map (FUNC=> FUNC_s, INPUT1=> INPUT1_s, INPUT2=>INPUT2_s, ALU_OUT=>ALU_OUT_s);

		VectProc:process
		begin
			INPUT1_s <= X"00000035"; INPUT2_s <= X"00000068";
			FUNC_s <= ADD;
			wait for 5 ns;
			assert (ALU_OUT_s=X"0000009D");

			FUNC_s <= SUB;
			wait for 5 ns;
			assert (ALU_OUT_s=X"FFFFFFCD");

			FUNC_s <= MULT;
			wait for 5 ns;
			assert (ALU_OUT_s=X"00001588");

			FUNC_s <= BITAND;
			wait for 5 ns;
			assert (ALU_OUT_s=X"00000020");

			FUNC_s <= BITOR;
			wait for 5 ns;
			assert (ALU_OUT_s=X"0000007D");

			FUNC_s <= BITXOR;
			wait for 5 ns;
			assert (ALU_OUT_s=X"0000005D");

			INPUT2_s <= X"00000005";

			FUNC_s <= FUNCLSL;
			wait for 5 ns;
			assert (ALU_OUT_s=X"000006A0");

			FUNC_s <= FUNCLSR;
			wait for 5 ns;
			assert (ALU_OUT_s=X"00000001");

			FUNC_s <= FUNCASL;
			wait for 5 ns;
			assert (ALU_OUT_s=X"000006A0");

			FUNC_s <= FUNCASR;
			wait for 5 ns;
			assert (ALU_OUT_s=X"00000001");

			FUNC_s <= FUNCRL;
			wait for 5 ns;
			assert (ALU_OUT_s=X"000006A0");

			FUNC_s <= FUNCRR;
			wait for 5 ns;
			assert (ALU_OUT_s=X"A8000001");

			wait;
			--type TYPE_OP is (ADD, SUB, MULT, BITAND, BITOR, BITXOR, FUNCLSL, FUNCLSR, FUNCASL, FUNCASR, FUNCRL, FUNCRR);
		end process VectProc;
end simple_tb_alu_test;