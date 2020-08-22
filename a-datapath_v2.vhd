library ieee;
use ieee.std_logic_1164.all;
use WORK.constants.all;
use WORK.alu_types.all;

entity datapath is
	Port (ALU_FUNC : in TYPE_OP;
		  A, B, IMM1, IMM2 : in std_logic_vector(0 to NUMBIT-1);
		  S1, S2 : in std_logic;
		  OUT1: out std_logic_vector(0 to NUMBIT-1);
		  RST, CLK: in std_logic);
end datapath;

architecture datapath_rt of datapath is

component simple_alu is
	port (	FUNC : IN TYPE_OP;
			INPUT1, INPUT2 : IN std_logic_vector(0 to NUMBIT-1);
			ALU_OUT : OUT std_logic_vector(0 to NUMBIT-1));
end component;

component register_32 is
	Port (D : in std_logic_vector(0 to NUMBIT-1);
		  Q : out std_logic_vector(0 to NUMBIT-1);
		  CLK, RST: in std_logic);
end component;

component mux21 is
  	Port (A:    in	std_logic_vector(0 to NUMBIT-1) ;
	      B:	in	std_logic_vector(0 to NUMBIT-1);
          SEL:	in	std_logic;
          Y:	out	std_logic_vector(0 to NUMBIT-1));
end component;

signal reg_IMM1_out, reg_IMM2_out, reg_A_out, reg_B_out : std_logic_vector(0 to NUMBIT-1);
signal OP1, OP2, ALU_OUT : std_logic_vector(0 to NUMBIT-1);

begin

reg_IMM1 : register_32 Port Map (D=> IMM1, Q=> reg_IMM1_out, CLK=> CLK, RST=> RST);
reg_A : register_32 Port Map (D=> A, Q=> reg_A_out, CLK=> CLK, RST=> RST);
reg_B : register_32 Port Map (D=> B, Q=> reg_B_out, CLK=> CLK, RST=> RST);
reg_IMM2 : register_32 Port Map (D=> IMM2, Q=> reg_IMM2_out, CLK=> CLK, RST=> RST);

mux_OP1 : mux21 Port Map (A=> reg_IMM1_out, B=> reg_A_out, SEL=> S1, Y=> OP1);
mux_OP2 : mux21 Port Map (A=> reg_B_out, B=> reg_IMM2_out, SEL=> S2, Y=> OP2);

ALU_1 : simple_alu Port Map (FUNC=> ALU_FUNC, INPUT1=> OP1, INPUT2=> OP2, ALU_OUT=> ALU_OUT);

reg_OUT : register_32 Port Map (D=> ALU_OUT, Q=> OUT1, CLK=> CLK, RST=> RST);

end datapath_rt;