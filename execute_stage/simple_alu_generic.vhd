library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simple_alu_generic is
    Generic (NBIT : integer := 32);
	port (	FUNC : IN std_logic_vector(0 to 3);
			INPUT1, INPUT2 : IN std_logic_vector(0 to NBIT-1);
			ALU_OUT : OUT std_logic_vector(0 to NBIT-1));
end simple_alu_generic;

architecture simple_alu_rt of simple_alu_generic is
begin

P_ALU: process(FUNC, INPUT1, INPUT2)
variable mul_tmp : std_logic_vector(0 to NBIT*2-1);
begin
	case FUNC is
		when "0000"	=>	ALU_OUT <= std_logic_vector(signed(INPUT1) + signed(INPUT2));
		when "0001"	=>  ALU_OUT <= std_logic_vector(signed(INPUT1) - signed(INPUT2));
--		when "0010"	=>	mul_tmp := (std_logic_vector(signed(INPUT1) * signed(INPUT2)));
--						ALU_OUT <= mul_tmp(NBIT to NBIT*2-1);
		when "0011"	=>	ALU_OUT <= (INPUT1 and INPUT2);
		when "0100"	=>	ALU_OUT <= (INPUT1 or INPUT2);
		when "0101"	=>	ALU_OUT <= (INPUT1 xor INPUT2);
		when "0110"=>  ALU_OUT <= std_logic_vector(shift_left(unsigned(INPUT1), to_integer(unsigned(INPUT2(NBIT-5 to NBIT-1)))));
		when "0111"=>  ALU_OUT <= std_logic_vector(shift_right(unsigned(INPUT1), to_integer(unsigned(INPUT2(NBIT-5 to NBIT-1)))));
		when "1000"=>	ALU_OUT <= std_logic_vector(shift_left(signed(INPUT1), to_integer(unsigned(INPUT2(NBIT-5 to NBIT-1)))));
		when "1001"=>  ALU_OUT <= std_logic_vector(shift_right(signed(INPUT1), to_integer(unsigned(INPUT2(NBIT-5 to NBIT-1)))));
		when "1010" =>	ALU_OUT <= std_logic_vector(rotate_left(unsigned(INPUT1), to_integer(unsigned(INPUT2))));
		when "1011" =>	ALU_OUT <= std_logic_vector(rotate_right(unsigned(INPUT1), to_integer(unsigned(INPUT2))));
		when "1100" => if(signed(INPUT1) >= signed(INPUT2)) then ALU_OUT<=(31=>'1', OTHERS=>'0'); else ALU_OUT<=(OTHERS=>'0'); end if;
		when "1101" => if(signed(INPUT1) <= signed(INPUT2)) then ALU_OUT<=(31=>'1', OTHERS=>'0'); else ALU_OUT<=(OTHERS=>'0'); end if;
		when "1110" => if(signed(INPUT1) /= signed(INPUT2)) then ALU_OUT<=(31=>'1', OTHERS=>'0'); else ALU_OUT<=(OTHERS=>'0'); end if;
		when "1111" => ALU_OUT <= (OTHERS=>'0');--nop
		when others => null;
	end case;
end process P_ALU;

end simple_alu_rt;