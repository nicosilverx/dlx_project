library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity writeback_stage is
    Port (LMD_out, ALU_out : in std_logic_vector(0 to 31);
          CLK, RST, flush, writeback_active, sel_wb_mux : in std_logic;
          WRITEBACK, DATAPATH_out : out std_logic_vector(0 to 31));
end writeback_stage;

architecture struct of writeback_stage is
--Components
component register_generic is
    Generic (NBIT : integer := 32;
             EDGE : std_logic := '1');
    Port (D: in std_logic_vector(0 to NBIT-1);
          Q: out std_logic_vector(0 to NBIT-1);
          CLK, RST, EN : in std_logic);
end component;
component mux2to1 is
    Generic (NBIT : integer := 32);
    Port (A, B : in std_logic_vector(0 to NBIT-1);
          SEL : in std_logic;
          OUTPUT : out std_logic_vector(0 to NBIT-1));
end component;

signal wb_mux_out : std_logic_vector(0 to 31) := (OTHERS=>'0');
signal internal_reset : std_logic := '1';

begin
internal_reset <= RST AND NOT(flush);
WRITEBACK <= wb_mux_out;
--Writeback mux
wb_mux : mux2to1 Port Map (A=> LMD_out, B=> ALU_out, SEL=> sel_wb_mux, OUTPUT=> wb_mux_out);
--Datapath reg
dp_reg : register_generic Port Map (D=> wb_mux_out, Q=> DATAPATH_out, CLK=> CLK, RST=> internal_reset, EN=> writeback_active);
end struct;
