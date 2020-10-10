library ieee;
use ieee.std_logic_1164.all;

entity fetch_stage_wrapper is
    Generic (NBIT : integer := 32);
    Port(PC_in : in std_logic_vector(0 to NBIT-1);
         NPC_out, IR_out : out std_logic_vector(0 to NBIT-1);
         CLK, RST, PC_EN, NPC_EN, IR_EN : in std_logic);
end fetch_stage_wrapper;

architecture rtl of fetch_stage_wrapper is
--Signals
signal ADDR_s, DOUT_s : std_logic_vector(31 downto 0);

--Fetch stage
component fetch_stage is
    Generic (NBIT : integer := 32);
    Port(PC_in, instruction_word_in : in std_logic_vector(0 to NBIT-1);
         PC_out, NPC_out, IR_out : out std_logic_vector(0 to NBIT-1);
         CLK, RST, PC_EN, NPC_EN, IR_EN : in std_logic);
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
fetch_component : fetch_stage Generic Map (NBIT=> 32) Port Map (PC_in=> PC_in, instruction_word_in=> DOUT_s, PC_out=> ADDR_s, NPC_out=> NPC_out,
  IR_out=> IR_out, CLK=> CLK, RST=> RST, PC_EN=> PC_EN, NPC_EN=> NPC_EN, IR_EN=> IR_EN);
--IRAM 
iram_component	: IRAM Generic Map (RAM_DEPTH=> 256, I_SIZE=> 32) Port Map (Rst=> RST, Addr=> ADDR_s, Dout=> DOUT_s);
end rtl;