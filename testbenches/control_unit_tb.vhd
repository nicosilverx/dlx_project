library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit_tb is
end control_unit_tb;

architecture test of control_unit_tb is
--Signals
signal D_OPCODE_s : std_logic_vector(0 to 5);
signal D_FUNC_s : std_logic_vector(0 to 10);
signal CLK_s, RST_s : std_logic := '0';
signal D_EN_RF_s, D_EN_READ1_s, D_EN_READ2_s, D_SEL_IMM_MUX_s, 
 D_EN_A_s, D_EN_B_s, D_EN_C_s, D_EN_IMM_s, D_EN_NPC_s, D_EN_WRITE_s, D_SEL_RD_MUX_s : std_logic;
signal E_SEL_OP1_MUX_s, E_SEL_OP2_MUX_s : std_logic;
signal E_ALU_FUNC_s : std_logic_vector(0 to 3);
signal E_EN_NPC_s, E_EN_ZERO_REG_s, E_EN_ALU_OUTPUT_s,
 E_EN_B_REG_s, E_EN_C_REG_s, E_EN_COMPARATOR_s, E_TYPE_OF_COMP_s : std_logic;
signal M_EN_READ_s, M_EN_WRITE_s, M_EN_LMD_REG_s, M_EN_ALU_OUTPUT_s, M_EN_C_REG_s, M_IS_LINK_s : std_logic;
signal W_SEL_WB_MUX_s, W_EN_DATAPATH_OUT_s : std_logic;
--DUT
component control_unit is
    Port (D_OPCODE : in std_logic_vector(0 to 5);
          D_FUNC : in std_logic_vector(0 to 10);
          CLK, RST : in std_logic;
          D_EN_RF, D_EN_READ1, D_EN_READ2, D_SEL_IMM_MUX, 
          D_EN_A, D_EN_B, D_EN_C, D_EN_IMM, D_EN_NPC, D_EN_WRITE, D_SEL_RD_MUX : out std_logic;
          E_SEL_OP1_MUX, E_SEL_OP2_MUX : out std_logic;
          E_ALU_FUNC : out std_logic_vector(0 to 3);
          E_EN_NPC, E_EN_ZERO_REG, E_EN_ALU_OUTPUT,
          E_EN_B_REG, E_EN_C_REG, E_EN_COMPARATOR, E_TYPE_OF_COMP : out std_logic;
          M_EN_READ, M_EN_WRITE, M_EN_LMD_REG, M_EN_ALU_OUTPUT, M_EN_C_REG, M_IS_LINK : out std_logic;
          W_SEL_WB_MUX, W_EN_DATAPATH_OUT : out std_logic);
end component;

begin

DUT: control_unit Port Map (D_OPCODE=>D_OPCODE_s, D_FUNC=>D_FUNC_s, CLK=>CLK_s, RST=>RST_s, D_EN_RF=> D_EN_RF_s,
    D_EN_READ1=> D_EN_READ1_s, D_EN_READ2=> D_EN_READ2_s, D_SEL_IMM_MUX=> D_SEL_IMM_MUX_s, D_EN_A=> D_EN_A_s, D_EN_B=> D_EN_B_s,
    D_EN_C=> D_EN_C_s, D_EN_IMM=> D_EN_IMM_s, D_EN_NPC=> D_EN_NPC_s, D_EN_WRITE=> D_EN_WRITE_s, D_SEL_RD_MUX=> D_SEL_RD_MUX_s, 
    E_SEL_OP1_MUX=>E_SEL_OP1_MUX_s, E_SEL_OP2_MUX=> E_SEL_OP2_MUX_s, E_ALU_FUNC=> E_ALU_FUNC_s, E_EN_NPC=> E_EN_NPC_s, E_EN_ZERO_REG=>E_EN_ZERO_REG_s,
    E_EN_ALU_OUTPUT=> E_EN_ALU_OUTPUT_s, E_EN_B_REG=> E_EN_B_REG_s, E_EN_C_REG=> E_EN_C_REG_s, E_EN_COMPARATOR=> E_EN_COMPARATOR_s, E_TYPE_OF_COMP=> E_TYPE_OF_COMP_s,
    M_EN_READ=> M_EN_READ_s, M_EN_WRITE=> M_EN_WRITE_s, M_EN_LMD_REG=> M_EN_LMD_REG_s, M_EN_ALU_OUTPUT=> M_EN_ALU_OUTPUT_s, M_EN_C_REG=> M_EN_C_REG_s, 
    M_IS_LINK=> M_IS_LINK_s, W_SEL_WB_MUX=> W_SEL_WB_MUX_s, W_EN_DATAPATH_OUT=> W_EN_DATAPATH_OUT_s);

ClkProc:process(CLK_s)
begin
    CLK_s <= NOT(CLK_s) after 0.5 ns;
end process ClkProc;

VectProc:process
begin
    D_OPCODE_s <= "000000"; D_FUNC_s <= "00000100000"; RST_s <= '0';
    WAIT UNTIL CLK_s='1' AND CLK_s'EVENT;
    RST_s <= '1';   --ADD
    WAIT UNTIL CLK_s='1' AND CLK_s'EVENT;
    D_OPCODE_s <= "000010"; D_FUNC_s <= "00000000000";  --J
    WAIT UNTIL CLK_s='1' AND CLK_s'EVENT;
    D_OPCODE_s <= "000000"; D_FUNC_s <= "00000000000";
    WAIT UNTIL CLK_s='1' AND CLK_s'EVENT;
    WAIT UNTIL CLK_s='1' AND CLK_s'EVENT;
    wait;
end process VectProc;


end test;
