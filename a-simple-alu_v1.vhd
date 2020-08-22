library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.alu_types.all;
use WORK.constants.all;

entity simple_alu is
	port (	FUNC : IN TYPE_OP;
			INPUT1, INPUT2 : IN std_logic_vector(0 to NUMBIT-1);
			ALU_OUT : OUT std_logic_vector(0 to NUMBIT-1));
end simple_alu;

architecture simple_alu_rt of simple_alu is
begin

P_ALU: process(FUNC, INPUT1, INPUT2)
variable mul_tmp : std_logic_vector(0 to NUMBIT*2-1);
begin
	case FUNC is
		when ADD	=>	ALU_OUT <= std_logic_vector(signed(INPUT1) + signed(INPUT2));
		when SUB	=>  ALU_OUT <= std_logic_vector(signed(INPUT1) - signed(INPUT2));
		when MULT	=>	mul_tmp := (std_logic_vector(signed(INPUT1) * signed(INPUT2)));
						ALU_OUT <= mul_tmp(NUMBIT to NUMBIT*2-1);
		when BITAND	=>	ALU_OUT <= (INPUT1 and INPUT2);
		when BITOR	=>	ALU_OUT <= (INPUT1 or INPUT2);
		when BITXOR	=>	ALU_OUT <= (INPUT1 xor INPUT2);
		when FUNCLSL=>  ALU_OUT <= std_logic_vector(shift_left(unsigned(INPUT1), to_integer(unsigned(INPUT2))));
		when FUNCLSR=>  ALU_OUT <= std_logic_vector(shift_right(unsigned(INPUT1), to_integer(unsigned(INPUT2))));
		when FUNCASL=>	ALU_OUT <= std_logic_vector(shift_left(signed(INPUT1), to_integer(unsigned(INPUT2))));
		when FUNCASR=>  ALU_OUT <= std_logic_vector(shift_right(signed(INPUT1), to_integer(unsigned(INPUT2))));
		when FUNCRL =>	ALU_OUT <= std_logic_vector(rotate_left(unsigned(INPUT1), to_integer(unsigned(INPUT2))));
		when FUNCRR =>	ALU_OUT <= std_logic_vector(rotate_right(unsigned(INPUT1), to_integer(unsigned(INPUT2))));
		when others => null;
	end case;
end process P_ALU;

end simple_alu_rt;