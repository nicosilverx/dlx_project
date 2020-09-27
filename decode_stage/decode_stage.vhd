library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decode_stage is
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

--Adder
component adder_generic is
    Generic (NBIT : integer := 32);
    Port (A, B : in std_logic_vector(0 to NBIT-1);
          S    : out std_logic_vector(0 to NBIT-1));
end component;

--Sign extender
component sign_extender_generic is
    Generic (NBIT_input: integer := 16;
             NBIT_output: integer := 32);
    Port (A : in std_logic_vector(0 to NBIT_input-1);
          O : out std_logic_vector(0 to NBIT_output-1));
end component;

--Comparator
component comparator_generic is
    Generic (NBIT: integer := 32);
    Port (A, B : in std_logic_vector(0 to NBIT-1);
          EN : in std_logic;
          EQ, GT, LT : out std_logic);
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

--Internal wires
signal opcode : std_logic_vector(0 to 5); --[0:5]
signal func   : std_logic_vector(0 to 10);--[21:31]
signal r1_to_rf, r2_to_rf, r3_to_rd :std_logic_vector(0 to 4);--[6:10],[11:15],[16:20]
signal rf_to_rs1, rf_to_rs2, rs1_to_comparator, rs2_to_comparator : std_logic_vector(0 to NBIT-1);
signal imm_to_se : std_logic_vector(0 to 15);--[16:31]
signal name_to_se: std_logic_vector(0 to 25);--[6:31]
signal se_to_imm_reg, se_to_adder : std_logic_vector(0 to NBIT-1);

begin
    OPCODE_out <= IR_in(0 to 5);
    FUNC_out   <= IR_in(21 to 31);
    r1_to_rf   <= IR_in(6 to 10);
    r2_to_rf   <= IR_in(11 to 15);
    r3_to_rd   <= IR_in(16 to 20);
    imm_to_se  <= IR_in(16 to 31);
    name_to_se <= IR_in(6 to 31);
    RS1_out <= rs1_to_comparator;
    RS2_out <= rs2_to_comparator;
    
--Integer Register File    
register_file : register_file_generic Generic Map (N_ROWS=> 32, NBIT_ADDRESS=> 5, NBIT_WORD=> 32)
    Port Map (CLK=> CLK, RST=> RST, EN=> RF_EN, RD1=> READ1_EN, RD2=> READ2_EN, WR=> WRITE_EN,
    ADD_WR=> RD_address, ADD_RD1=> r1_to_rf, ADD_RD2=> r2_to_rf, DATAIN=> RD_data, 
    OUT1=> rf_to_rs1, OUT2=> rf_to_rs2);    

--Sign extenders
sign_extender_imm : sign_extender_generic Generic Map (NBIT_input=> 16, NBIT_output=> 32)
    Port Map (A=> imm_to_se, O=> se_to_imm_reg);
sign_extender_name : sign_extender_generic Generic Map (NBIT_input=> 26, NBIT_output=> 32)
    Port Map (A=> name_to_se, O=> se_to_adder);    

--Pipe registers   
reg_RS1 : register_generic Generic Map (NBIT=> 32) Port Map (D=> rf_to_rs1, 
    Q=> rs1_to_comparator, CLK=> CLK, RST=> RST, EN=> RS1_EN );     
reg_RS2 : register_generic Generic Map (NBIT=> 32) Port Map (D=> rf_to_rs2, 
    Q=> rs2_to_comparator, CLK=> CLK, RST=> RST, EN=> RS2_EN );
reg_RS  : register_generic Generic Map (NBIT=> 5) Port Map (D=> r2_to_rf, 
    Q=> RS_out, CLK=> CLK, RST=> RST, EN=> RS_EN);
reg_RD  : register_generic Generic Map (NBIT=> 5) Port Map (D=> r3_to_rd,
    Q=> RD_out, CLK=> CLK, RST=> RST, EN=> RD_EN);
reg_IMM : register_generic Generic Map (NBIT=> 32) Port Map (D=> se_to_imm_reg,
    Q=> IMM_out, CLK=> CLK, RST=> RST, EN=> IMM_EN);          
    
--Adder for Jumps
adder : adder_generic Generic Map (NBIT=> 32) Port Map (A=> se_to_adder, B=> PC_in, S=> PC_out);            

--Comparator for branch
comparator : comparator_generic Generic Map (NBIT=> 32) Port Map (A=> rs1_to_comparator, B=> rs2_to_comparator,
    EN=> IS_BRANCH, EQ=> IS_EQUAL, GT=> open, LT=> open);
end rtl;
