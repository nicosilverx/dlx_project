library ieee;
use ieee.std_logic_1164.all;

entity fetch_stage_wrapper is
    Generic (NBIT : integer := 32);
    Port( next_pc: in std_logic_vector(0 to NBIT-1);
          SEL_MUX1, PC_EN, IR_EN, CLK, RST: in std_logic;
          IR_out, PC_new : out std_logic_vector(0 to NBIT-1));
end fetch_stage_wrapper;

architecture rtl of fetch_stage_wrapper is
--Signals
signal RST_s : std_logic;
signal ADDR_s, DOUT_s : std_logic_vector(31 downto 0);

--Fetch stage
component fetch_stage is
    Generic (NBIT : integer := 32);
    Port( next_pc, instruction_word : in std_logic_vector(0 to NBIT-1);
          SEL_MUX1, PC_EN, IR_EN, CLK, RST: in std_logic;
          IR_out, PC_out, PC_new : out std_logic_vector(0 to NBIT-1));
end component;
--IRAM
component IRAM is
  generic (
    RAM_DEPTH : integer := 48;
    I_SIZE : integer := 32);
  port (
    Rst  : in  std_logic;
    Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
    Dout : out std_logic_vector(I_SIZE - 1 downto 0)
    );

end component;

begin
--Fetch stage
fetch_component : fetch_stage Generic Map (NBIT=> NBIT) Port Map (next_pc=> next_pc, 
	instruction_word=> DOUT_s, SEL_MUX1=> SEL_MUX1, PC_EN=> PC_EN, IR_EN=> IR_EN, CLK=> CLK, RST=> RST,
	IR_out=> IR_out, PC_out=> ADDR_s, PC_new=> PC_new);
--IRAM 
iram_component	: IRAM Generic Map (RAM_DEPTH=> 48, I_SIZE=> 32) Port Map (Rst=> RST, Addr=> ADDR_s, Dout=> DOUT_s);
end rtl;