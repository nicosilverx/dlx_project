library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dlx is
    Port(CLK, RST : in std_logic;
         datapath_out : out std_logic_vector(0 to 31));
end dlx;

architecture struct of dlx is
--Dp
component datapath is
    Port(Datapath_out : out std_logic_vector(0 to 31);
         CLK, RST : in std_logic;
         D_EN_WRITE, D_EN_READ1, D_EN_READ2, D_SEL_IMM_MUX, D_SEL_RD_MUX : in std_logic;
         E_SEL_OP1_MUX : in std_logic;
         E_SEL_OP2_MUX : in std_logic_vector(0 to 1);
         E_ALU_FUNC : in std_logic_vector(0 to 3);
         E_EN_WRITE_NOW : in std_logic;
         M_EN_READ, M_EN_WRITE, M_IS_LINK : in std_logic;
         W_SEL_WB_MUX : in std_logic;
         Opcode : out std_logic_vector(0 to 5);
         Func : out std_logic_vector(0 to 10);
         jump_taken_n : in std_logic;
         flush : in std_logic;
         stall_out : out std_logic);
end component;
--cu
component control_unit is
    Port(Opcode : in std_logic_vector(0 to 5);
         Func   : in std_logic_vector(0 to 10);
         CLK, RST : in std_logic;
         D_EN_WRITE, D_EN_READ1, D_EN_READ2, D_SEL_IMM_MUX, D_SEL_RD_MUX : out std_logic;
         E_SEL_OP1_MUX : out std_logic;
         E_SEL_OP2_MUX : out std_logic_vector(0 to 1);
         E_ALU_FUNC : out std_logic_vector(0 to 3);
         E_EN_WRITE_NOW : out std_logic;
         M_EN_READ, M_EN_WRITE, M_IS_LINK : out std_logic;
         W_SEL_WB_MUX : out std_logic;
         jump_taken_n : out std_logic;
         flush : out std_logic;
         stall_in : in std_logic);
end component;
--Wires
signal D_EN_WRITE, D_EN_READ1, D_EN_READ2, D_SEL_IMM_MUX, D_SEL_RD_MUX :  std_logic := '0';
signal E_SEL_OP1_MUX :  std_logic := '0';
signal E_SEL_OP2_MUX :  std_logic_vector(0 to 1) := (OTHERS=>'0');
signal E_ALU_FUNC :  std_logic_vector(0 to 3) := (OTHERS=>'0');
signal M_EN_READ, M_EN_WRITE, M_IS_LINK :  std_logic := '0';
signal W_SEL_WB_MUX, E_EN_WRITE_NOW :  std_logic := '0';
signal Opcode :  std_logic_vector(0 to 5) := (OTHERS=>'0');
signal Func :  std_logic_vector(0 to 10) := (OTHERS=>'0');
signal jump_taken_n, flush, stall_to_cu: std_logic := '1';

begin
--Dp
datapath_s : datapath Port Map (Datapath_out=> datapath_out, CLK=> CLK, RST=> RST, 
    D_EN_WRITE=> D_EN_WRITE, D_EN_READ1=> D_EN_READ1, D_EN_READ2=> D_EN_READ2, D_SEL_IMM_MUX=> D_SEL_IMM_MUX, D_SEL_RD_MUX=> D_SEL_RD_MUX,
    E_SEL_OP1_MUX=> E_SEL_OP1_MUX, E_SEL_OP2_MUX=> E_SEL_OP2_MUX, E_ALU_FUNC=> E_ALU_FUNC, E_EN_WRITE_NOW=> E_EN_WRITE_NOW,
     M_EN_READ=> M_EN_READ, M_EN_WRITE=> M_EN_WRITE, M_IS_LINK=> M_IS_LINK,
    W_SEL_WB_MUX=> W_SEL_WB_MUX, Opcode=> Opcode, Func=> Func, jump_taken_n=> jump_taken_n, flush=> flush, stall_out=> stall_to_cu);
--Cu
control_unit_s : control_unit Port Map (Opcode=> Opcode, Func=> Func, CLK=> CLK, RST=> RST, 
    D_EN_WRITE=> D_EN_WRITE, D_EN_READ1=> D_EN_READ1, D_EN_READ2=> D_EN_READ2, D_SEL_IMM_MUX=> D_SEL_IMM_MUX, D_SEL_RD_MUX=> D_SEL_RD_MUX,
    E_SEL_OP1_MUX=> E_SEL_OP1_MUX, E_SEL_OP2_MUX=> E_SEL_OP2_MUX, E_ALU_FUNC=> E_ALU_FUNC, E_EN_WRITE_NOW=> E_EN_WRITE_NOW,
    M_EN_READ=> M_EN_READ, M_EN_WRITE=> M_EN_WRITE, M_IS_LINK=> M_IS_LINK, W_SEL_WB_MUX=> W_SEL_WB_MUX, jump_taken_n=> jump_taken_n, flush=> flush,
    stall_in=> stall_to_cu);

end struct;
