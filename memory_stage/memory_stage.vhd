library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity memory_stage is
    Generic (NBIT : integer := 32);
    Port (ALU_output, B_in : in std_logic_vector(0 to NBIT-1);
          C_in : in std_logic_vector(0 to 4);
          CLK, RST, EN_READ, EN_WRITE, EN_LMD_reg, EN_ALU_output_reg, EN_C_reg, is_link : in std_logic;
          NPC_out, LMD_out, ALU_reg_out : out std_logic_vector(0 to NBIT-1);
          C_out : out std_logic_vector(0 to 4));
end memory_stage;

architecture rtl of memory_stage is
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
--Dram
component dram is
    Generic (RAM_DEPTH : integer := 48;
             D_SIZE : integer := 32);
    Port (ADDR, DATAIN : in std_logic_vector(0 to D_SIZE-1);
          DOUT : out std_logic_vector(0 to D_SIZE-1);
          RST, READ, WRITE : in std_logic);             
end component;
--Internal wires
signal ALU_bus, DRAM_out : std_logic_vector(0 to NBIT-1);
signal c_mux_out : std_logic_vector(0 to 4);

begin

NPC_out <= ALU_output;

DRAM_1 : dram Generic Map (RAM_DEPTH=> 48, D_SIZE=> 32)
    Port Map (ADDR=> ALU_output, DATAIN=> B_in, DOUT=> DRAM_out, RST=> RST, READ=> EN_READ, WRITE=> EN_WRITE);

LMD_reg : register_generic Generic Map (NBIT=> 32) Port Map (D=> DRAM_out, Q=> LMD_out, 
    CLK=> CLK, RST=> RST, EN=> EN_LMD_reg);
ALU_output_reg : register_generic Generic Map (NBIT=> 32) Port Map (D=> ALU_output, Q=> ALU_reg_out, 
    CLK=> CLK, RST=> RST, EN=> EN_ALU_output_reg);  
C_reg : register_generic Generic Map (NBIT=> 5) Port Map (D=> c_mux_out, Q=> C_out, CLK=> CLK,
    RST=> RST, EN=> EN_C_reg);

c_mux : mux2to1_generic Generic Map (NBIT=> 5) Port Map (A=> "11111", B=> C_in, SEL=> is_link, OUTPUT=> c_mux_out);

end rtl;
