library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity writeback_stage is
    Generic (NBIT: integer := 32);
    Port (LMD_out, ALU_out : in std_logic_vector(0 to NBIT-1);
          CLK, RST, EN_DATAPATH_out, sel_wb_mux, flush_stage : in std_logic;
          WRITEBACK, DATAPATH_out : out std_logic_vector(0 to NBIT-1));
end writeback_stage;

architecture rtl of writeback_stage is
--Components
--Register
component register_generic is
    Generic (NBIT : integer := 32);
    Port (D: in std_logic_vector(0 to NBIT-1);
          Q: out std_logic_vector(0 to NBIT-1);
          CLK, RST, EN : in std_logic);
end component;
--Multiplexer
component mux2to1_generic is
    Generic (NBIT : integer := 32);
    Port (A, B : in std_logic_vector(0 to NBIT-1);
          SEL : in std_logic;
          OUTPUT : out std_logic_vector(0 to NBIT-1));
end component;

--Internal wires
signal DATAPATH_out_bus : std_logic_vector(0 to NBIT-1);

begin

WRITEBACK <= DATAPATH_out_bus;

wb_mux : mux2to1_generic Generic Map (NBIT=> 32)
    Port Map (A=> LMD_out, B=> ALU_out, SEL=> sel_wb_mux, OUTPUT=> DATAPATH_out_bus);
    
DP_out_reg : register_generic Generic Map (NBIT=> 32)
    Port Map (D=> DATAPATH_out_bus, Q=> DATAPATH_out, CLK=> CLK, RST=> flush_stage, EN=> EN_DATAPATH_out);    
end rtl;
