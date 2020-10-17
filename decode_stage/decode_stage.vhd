library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decode_stage is
    Port(NPC_in, IR_in, WB_datain : in std_logic_vector(0 to 31);
         WB_add : in std_logic_vector(0 to 4);
         EN_READ1, EN_READ2, EN_WRITE, decode_active, sel_imm_mux, sel_rd_mux, flush, CLK, RST : in std_logic;
         NPC_out, A_out, B_out, IMM_out : out std_logic_vector(0 to 31);
         C_out, Rd_out : out std_logic_vector(0 to 4);
         Opcode_out : out std_logic_vector(0 to 5);
         Func_out   : out std_logic_vector(0 to 10));
end decode_stage;

architecture struct of decode_stage is
--Components
component register_generic is
    Generic (NBIT : integer := 32;
             EDGE : std_logic := '1');
    Port (D: in std_logic_vector(0 to NBIT-1);
          Q: out std_logic_vector(0 to NBIT-1);
          CLK, RST, EN : in std_logic);
end component;
component sign_extender_generic is
    Generic (NBIT_input: integer := 16;
             NBIT_output: integer := 32);
    Port (A : in std_logic_vector(0 to NBIT_input-1);
          O : out std_logic_vector(0 to NBIT_output-1));
end component;
component register_file is
    Generic (N_ROWS       : integer := 32;
             NBIT_ADDRESS : integer := 5;
             NBIT_WORD    : integer := 32);
	Port (CLK, RST, EN, RD1, RD2, WR: in std_logic;
		  ADD_WR, ADD_RD1, ADD_RD2  : in std_logic_vector(0 to NBIT_ADDRESS-1);
		  DATAIN : in std_logic_vector(0 to NBIT_WORD-1);
		  OUT1, OUT2 : out std_logic_vector(0 to NBIT_WORD-1));
end component;
component mux2to1 is
    Generic (NBIT : integer := 32);
    Port (A, B : in std_logic_vector(0 to NBIT-1);
          SEL : in std_logic;
          OUTPUT : out std_logic_vector(0 to NBIT-1));
end component;
component adder is
    Port (A, B : in std_logic_vector(0 to 31);
          S    : out std_logic_vector(0 to 31));
end component;
--Wires
signal rs1, rs2, rd : std_logic_vector(0 to 4) := (OTHERS=>'0');
signal name : std_logic_vector(0 to 25) := (OTHERS=>'0');
signal imm : std_logic_vector(0 to 15) := (OTHERS=>'0');
signal ir_mux_out, se1_out, se2_out, out1, out2, imm_mux_out, npc_adder_to_npc : std_logic_vector(0 to 31) := (OTHERS=>'0');
signal rd_mux_out : std_logic_vector(0 to 4) := (OTHERS=>'0');
signal internal_reset : std_logic := '1';

begin
internal_reset <= RST AND NOT(flush);
Opcode_out <= IR_in(0 to 5);
Func_out <= IR_in(21 to 31);
rd_out <= rd_mux_out;
--NPC adder
npc_adder : adder Port Map (A=> NPC_in, B=> imm_mux_out, S=> npc_adder_to_npc);
--RF
int_rf : register_file Generic Map (N_ROWS=> 32, NBIT_ADDRESS=> 5, NBIT_WORD=> 32)
    Port Map (CLK=> CLK, RST=> RST, EN=> '1', RD1=> EN_READ1, RD2=> EN_READ2, WR=> EN_WRITE,
    ADD_WR=> WB_add, ADD_RD1=> IR_in(6 to 10), ADD_RD2=> IR_in(11 to 15), DATAIN=> WB_datain, OUT1=> out1, OUT2=> out2);
--Sign extenders
se_1 : sign_extender_generic Generic Map (NBIT_input=> 26, NBIT_output=> 32)
    Port Map (A=> IR_in(6 to 31), O=> se1_out);    
se_2 : sign_extender_generic Generic Map (NBIT_input=> 16, NBIT_output=> 32)
    Port Map (A=> IR_in(16 to 31), O=> se2_out);
--Immediate mux
imm_mux : mux2to1 Port Map (A=> se1_out, B=>se2_out, SEL=> sel_imm_mux, OUTPUT=> imm_mux_out);
--Rd mux
rd_mux : mux2to1 Generic Map (NBIT=> 5) Port Map (A=> IR_in(16 to 20), B=> IR_in(11 to 15), SEL=> sel_rd_mux, OUTPUT=> rd_mux_out);    

--NPC
reg_NPC : register_generic Port Map (D=> npc_adder_to_npc, Q=> NPC_out, CLK=> CLK, RST=> internal_reset, EN=> decode_active);
--A
reg_A : register_generic Port Map (D=> out1, Q=> A_out, CLK=> CLK, RST=> internal_reset , EN=> decode_active);
--B
reg_B : register_generic Port Map (D=> out2, Q=> B_out, CLK=> CLK, RST=> internal_reset , EN=> decode_active);
--C
reg_C : register_generic Generic Map (NBIT=> 5) Port Map (D=> rd_mux_out, Q=> C_out, CLK=> CLK, RST=> internal_reset, EN=> decode_active);
--IMM
reg_IMM : register_generic Port Map (D=> imm_mux_out, Q=> IMM_out, CLK=> CLK, RST=> internal_reset, EN=> decode_active); 
end struct;
