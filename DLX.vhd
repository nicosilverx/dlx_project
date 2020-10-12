library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DLX is
    Port (CLK, RST : in std_logic;
          datapath_out : out std_logic_vector(0 to 31));
end DLX;

architecture rtl of DLX is
--Datapath
component datapath is
    Port ( D_EN_RF, D_EN_READ1, D_EN_READ2, D_SEL_IMM_MUX, 
           D_EN_A, D_EN_B, D_EN_C, D_EN_IMM, D_EN_NPC, D_EN_WRITE, D_SEL_RD_MUX : in std_logic;
           E_SEL_OP1_MUX, E_SEL_OP2_MUX : in std_logic;
           E_ALU_FUNC : in std_logic_vector(0 to 3);
           E_EN_NPC, E_EN_ZERO_REG, E_EN_ALU_OUTPUT,
           E_EN_B_REG, E_EN_C_REG, E_EN_COMPARATOR, E_TYPE_OF_COMP : in std_logic;
           M_EN_READ, M_EN_WRITE, M_EN_LMD_REG, M_EN_ALU_OUTPUT, M_EN_C_REG, M_IS_LINK : in std_logic;
           W_SEL_WB_MUX, W_EN_DATAPATH_OUT : in std_logic;
           CLK, RST : in std_logic;
           D_OPCODE : out std_logic_vector(0 to 5);
           D_FUNC : out std_logic_vector(0 to 10);
           datapath_out : out std_logic_vector(0 to 31));
end component;
--Control Unit
component control_unit is
    Port (D_OPCODE : in std_logic_vector(0 to 5);
          D_FUNC : in std_logic_vector(0 to 10);
          CLK, RST : in std_logic;
          D_EN_RF, D_EN_READ1, D_EN_READ2, D_SEL_IMM_MUX, 
          D_EN_A, D_EN_B, D_EN_C, D_EN_IMM, D_EN_NPC, D_EN_WRITE, D_SEL_RD_MUX : out std_logic;
          E_SEL_OP1_MUX, E_SEL_OP2_MUX : out std_logic;
          E_ALU_FUNC : out std_logic_vector(0 to 3);
          E_EN_ZERO_REG, E_EN_ALU_OUTPUT,
          E_EN_B_REG, E_EN_C_REG, E_EN_COMPARATOR, E_TYPE_OF_COMP : out std_logic;
          M_EN_READ, M_EN_WRITE, M_EN_LMD_REG, M_EN_ALU_OUTPUT, M_EN_C_REG, M_IS_LINK : out std_logic;
          W_SEL_WB_MUX, W_EN_DATAPATH_OUT : out std_logic);
end component;

--Internal wires
signal D_OPCODE : std_logic_vector(0 to 5);
signal D_FUNC : std_logic_vector(0 to 10);
signal D_EN_RF, D_EN_READ1, D_EN_READ2, D_SEL_IMM_MUX, 
 D_EN_A, D_EN_B, D_EN_C, D_EN_IMM, D_EN_NPC, D_EN_WRITE, D_SEL_RD_MUX : std_logic;
signal E_SEL_OP1_MUX, E_SEL_OP2_MUX : std_logic;
signal E_ALU_FUNC : std_logic_vector(0 to 3);
signal E_EN_NPC, E_EN_ZERO_REG, E_EN_ALU_OUTPUT,
 E_EN_B_REG, E_EN_C_REG, E_EN_COMPARATOR, E_TYPE_OF_COMP : std_logic;
signal M_EN_READ, M_EN_WRITE, M_EN_LMD_REG, M_EN_ALU_OUTPUT, M_EN_C_REG, M_IS_LINK : std_logic;
signal W_SEL_WB_MUX, W_EN_DATAPATH_OUT : std_logic;

begin

dp : datapath Port Map (
    D_EN_RF=> D_EN_RF, D_EN_READ1=> D_EN_READ1, D_EN_READ2=> D_EN_READ2, D_SEL_IMM_MUX=> D_SEL_IMM_MUX,
    D_EN_A=> D_EN_A, D_EN_B=> D_EN_B, D_EN_C=> D_EN_C, D_EN_IMM=> D_EN_IMM, D_EN_NPC=> D_EN_NPC, D_EN_WRITE=> D_EN_WRITE, D_SEL_RD_MUX=> D_SEL_RD_MUX,
    E_SEL_OP1_MUX=> E_SEL_OP1_MUX, E_SEL_OP2_MUX=> E_SEL_OP2_MUX, 
    E_ALU_FUNC=> E_ALU_FUNC, 
    E_EN_NPC=> E_EN_NPC, E_EN_ZERO_REG=> E_EN_ZERO_REG, E_EN_ALU_OUTPUT=> E_EN_ALU_OUTPUT, 
    E_EN_B_REG=> E_EN_B_REG, E_EN_C_REG=> E_EN_C_REG, E_EN_COMPARATOR=> E_EN_COMPARATOR, E_TYPE_OF_COMP=> E_TYPE_OF_COMP,
    M_EN_READ=> M_EN_READ, M_EN_WRITE=> M_EN_WRITE, M_EN_LMD_REG=> M_EN_LMD_REG, M_EN_ALU_OUTPUT=> M_EN_ALU_OUTPUT, M_EN_C_REG=> M_EN_C_REG, M_IS_LINK=> M_IS_LINK,
    W_SEL_WB_MUX=> W_SEL_WB_MUX, W_EN_DATAPATH_OUT=> W_EN_DATAPATH_OUT,
    CLK=> CLK, RST=> RST, D_OPCODE=> D_OPCODE, D_FUNC=> D_FUNC, datapath_out=> datapath_out);
    
cu : control_unit Port Map (
    D_OPCODE=> D_OPCODE, D_FUNC=> D_FUNC, CLK=> CLK, RST=> RST,
     D_EN_RF=> D_EN_RF, D_EN_READ1=> D_EN_READ1, D_EN_READ2=> D_EN_READ2, D_SEL_IMM_MUX=> D_SEL_IMM_MUX,
     D_EN_A=> D_EN_A, D_EN_B=> D_EN_B, D_EN_C=> D_EN_C, D_EN_IMM=> D_EN_IMM, D_EN_NPC=> D_EN_NPC, D_EN_WRITE=> D_EN_WRITE, D_SEL_RD_MUX=> D_SEL_RD_MUX,
    E_SEL_OP1_MUX=> E_SEL_OP1_MUX, E_SEL_OP2_MUX=> E_SEL_OP2_MUX, 
    E_ALU_FUNC=> E_ALU_FUNC, 
    E_EN_ZERO_REG=> E_EN_ZERO_REG, E_EN_ALU_OUTPUT=> E_EN_ALU_OUTPUT, 
    E_EN_B_REG=> E_EN_B_REG, E_EN_C_REG=> E_EN_C_REG, E_EN_COMPARATOR=> E_EN_COMPARATOR, E_TYPE_OF_COMP=> E_TYPE_OF_COMP,
    M_EN_READ=> M_EN_READ, M_EN_WRITE=> M_EN_WRITE, M_EN_LMD_REG=> M_EN_LMD_REG, M_EN_ALU_OUTPUT=> M_EN_ALU_OUTPUT, M_EN_C_REG=> M_EN_C_REG, M_IS_LINK=> M_IS_LINK,
    W_SEL_WB_MUX=> W_SEL_WB_MUX, W_EN_DATAPATH_OUT=> W_EN_DATAPATH_OUT);    
    
end rtl;
