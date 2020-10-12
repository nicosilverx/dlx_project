library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decode_stage is
    Generic (NBIT : integer := 32);
    Port (NPC_in, IR_in, WB_datain : in std_logic_vector(0 to NBIT-1);
          WB_add : in std_logic_vector(0 to 4);
          NPC_out, A_out, B_out, IMM_out : out std_logic_vector(0 to NBIT-1);
          C_out : out std_logic_vector(0 to 4);
          Opcode_out : out std_logic_vector(0 to 5);
          Func_out   : out std_logic_vector(0 to 10);
          EN_READ1, EN_READ2, EN_WRITE, EN_RF, EN_A, EN_B, EN_C, EN_IMM, EN_NPC, sel_imm_mux, sel_rd_mux, CLK, RST : in std_logic); 
end decode_stage;

architecture rtl of decode_stage is
--Components
--Register
component register_generic is
    Generic (NBIT : integer := 32);
    Port (D: in std_logic_vector(0 to NBIT-1);
          Q: out std_logic_vector(0 to NBIT-1);
          CLK, RST, EN : in std_logic);
end component;

--Sign extender
component sign_extender_generic is
    Generic (NBIT_input: integer := 16;
             NBIT_output: integer := 32);
    Port (A : in std_logic_vector(0 to NBIT_input-1);
          O : out std_logic_vector(0 to NBIT_output-1));
end component;

--Register file
component register_file_generic is
    Generic (N_ROWS       : integer := 32;
             NBIT_ADDRESS : integer := 5;
             NBIT_WORD    : integer := 32);
	Port (CLK, RST, EN, RD1, RD2, WR: in std_logic;
		  ADD_WR, ADD_RD1, ADD_RD2  : in std_logic_vector(0 to NBIT_ADDRESS-1);
		  DATAIN : in std_logic_vector(0 to NBIT_WORD-1);
		  OUT1, OUT2 : out std_logic_vector(0 to NBIT_WORD-1));
end component;

--Multiplexer
component mux2to1_generic is
    Generic (NBIT : integer := 32);
    Port (A, B : in std_logic_vector(0 to NBIT-1);
          SEL : in std_logic;
          OUTPUT : out std_logic_vector(0 to NBIT-1));
end component;

--Internal wires
--signal opcode : std_logic_vector(0 to 5); --[0:5]
--signal func   : std_logic_vector(0 to 10);--[21:31]
signal rs1, rs2, rd : std_logic_vector(0 to 4);
signal name : std_logic_vector(0 to 25);
signal imm : std_logic_vector(0 to 15);
signal se1_out, se2_out, out1, out2, imm_mux_out : std_logic_vector(0 to NBIT-1);
signal rd_mux_out : std_logic_vector(0 to 4);
begin

--NPC_out <= NPC_in;
Opcode_out <= IR_in(0 to 5);
Func_out <= IR_in(21 to 31);
rs1 <= IR_in(6 to 10);
rs2 <= IR_in(11 to 15);
rd <= IR_in(16 to 20);
name <= IR_in(6 to 31);
imm <= IR_in(16 to 31);

--Register File
int_rf : register_file_generic Generic Map (N_ROWS=> 32, NBIT_ADDRESS=> 5, NBIT_WORD=> 32)
    Port Map (CLK=> CLK, RST=> RST, EN=> '1', RD1=> EN_READ1, RD2=> EN_READ2, WR=> EN_WRITE,
    ADD_WR=> WB_add, ADD_RD1=> rs1, ADD_RD2=> rs2, DATAIN=> WB_datain, OUT1=> out1, OUT2=> out2);
--Sign extender
se_1 : sign_extender_generic Generic Map (NBIT_input=> 26, NBIT_output=> 32)
    Port Map (A=> name, O=> se1_out);    
se_2 : sign_extender_generic Generic Map (NBIT_input=> 16, NBIT_output=> 32)
    Port Map (A=> imm, O=> se2_out);
    
--Multiplexer
imm_mux : mux2to1_generic Generic Map (NBIT=> 32) Port Map (A=> se1_out, B=>se2_out, 
    SEL=> sel_imm_mux, OUTPUT=> imm_mux_out);
rd_mux : mux2to1_generic Generic Map (NBIT=> 5) Port Map (A=> rd, B=> rs2, SEL=> sel_rd_mux, OUTPUT=> rd_mux_out);    
    
--Registers
reg_NPC : register_generic Generic Map (NBIT=> 32) Port Map (D=> NPC_in, Q=> NPC_out,
    CLK=> CLK, RST=> RST, EN=> EN_NPC);

reg_A : register_generic Generic Map (NBIT=> 32) Port Map (D=> out1, Q=> A_out, 
    CLK=> CLK, RST=> RST, EN=> EN_A);
reg_B : register_generic Generic Map (NBIT=> 32) Port Map (D=> out2, Q=> B_out, 
    CLK=> CLK, RST=> RST, EN=> EN_B);
reg_C : register_generic Generic Map (NBIT=> 5) Port Map (D=> rd_mux_out, Q=> C_out, 
    CLK=> CLK, RST=> RST, EN=> EN_C);        
reg_IMM : register_generic Generic Map (NBIT=> 32) Port Map (D=> imm_mux_out, Q=> IMM_out, 
    CLK=> CLK, RST=> RST, EN=> EN_IMM);   
end rtl;
