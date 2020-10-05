library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity writeback_tb is
end writeback_tb;

architecture test of writeback_tb is
--Signal
signal LMD_out_s, ALU_out_s :  std_logic_vector(0 to 31);
signal CLK_s, RST_s, EN_DATAPATH_out_s, sel_wb_mux_s :  std_logic :='1';
signal WRITEBACK_s, DATAPATH_out_s :  std_logic_vector(0 to 31);
--Component
component writeback_stage is
    Generic (NBIT: integer := 32);
    Port (LMD_out, ALU_out : in std_logic_vector(0 to NBIT-1);
          CLK, RST, EN_DATAPATH_out, sel_wb_mux : in std_logic;
          WRITEBACK, DATAPATH_out : out std_logic_vector(0 to NBIT-1));
end component;

begin

DUT: writeback_stage Generic Map (NBIT=> 32)
    Port Map (LMD_out=> LMD_out_s, ALU_out=> ALU_out_s,
              CLK=> CLK_s, RST=> RST_s, EN_DATAPATH_out=> EN_DATAPATH_out_s, sel_wb_mux=> sel_wb_mux_s,
              WRITEBACK=> WRITEBACK_s, DATAPATH_out=> DATAPATH_out_s);
              
ClkProc:process(CLK_s)
begin
    CLK_s <= NOT(CLK_s) after 0.5 ns;
end process ClkProc;              

VectProc:process
begin
    RST_s<='1'; EN_DATAPATH_out_s<='1'; sel_wb_mux_s<='1';
    LMD_out_s<=X"AAAAAAAA"; ALU_out_s<=X"bbbbbbbb";
    wait until CLK_s='1' AND CLK_s'EVENT;
    RST_s<='0';
    wait until CLK_s='1' AND CLK_s'EVENT;
    sel_wb_mux_s<='0';
    wait until CLK_s='1' AND CLK_s'EVENT;
    wait;
end process VectProc;
end test;
