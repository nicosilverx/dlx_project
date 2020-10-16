library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    Port (D_OPCODE : in std_logic_vector(0 to 5);
          D_FUNC : in std_logic_vector(0 to 10);
          CLK, RST : in std_logic;
          D_EN_RF, D_EN_READ1, D_EN_READ2, D_SEL_IMM_MUX, 
          D_EN_A, D_EN_B, D_EN_C, D_EN_IMM, D_EN_NPC, D_EN_WRITE, D_EN_WRITE_DECODE, D_SEL_RD_MUX, D_IS_JUMP : out std_logic;
          E_SEL_OP1_MUX, E_SEL_OP2_MUX : out std_logic;
          E_ALU_FUNC : out std_logic_vector(0 to 3);
          E_EN_ZERO_REG, E_EN_ALU_OUTPUT,
          E_EN_B_REG, E_EN_C_REG, E_EN_COMPARATOR, E_TYPE_OF_COMP, E_IS_JUMP : out std_logic;
          M_EN_READ, M_EN_WRITE, M_EN_LMD_REG, M_EN_ALU_OUTPUT, M_EN_C_REG, M_IS_LINK, M_IS_JUMP: out std_logic;
          W_SEL_WB_MUX, W_EN_DATAPATH_OUT : out std_logic);
end control_unit;

architecture rtl of control_unit is
--Components
component register_generic is
    Generic (NBIT : integer := 32);
    Port (D: in std_logic_vector(0 to NBIT-1);
          Q: out std_logic_vector(0 to NBIT-1);
          CLK, RST, EN : in std_logic);
end component;
--Signals
signal control_word : std_logic_vector(0 to 23) := (OTHERS=>'0'); --24 control signals
signal cw_execute : std_logic_vector(0 to 16) := (OTHERS=>'0'); --17 control signals
signal cw_memory : std_logic_vector(0 to 7) := (OTHERS=>'0'); --8 control signals
signal cw_writeback : std_logic_vector(0 to 2) := (OTHERS=>'0');

begin

D_EN_A<=control_word(0); D_EN_B<=control_word(0); 
D_EN_C<=control_word(0); D_EN_IMM<=control_word(0); D_EN_NPC<=control_word(0);
D_EN_RF<=control_word(1);
D_EN_READ1<=control_word(2);
D_EN_READ2<=control_word(3);
D_SEL_IMM_MUX<=control_word(4);--(5) is D_EN_WRITE

D_SEL_RD_MUX<=control_word(6);
D_IS_JUMP<=control_word(7);

reg_1 : register_generic Generic Map (NBIT=> 17) Port Map (D(0)=>control_word(5), 
    D(1 to 16)=>control_word(8 to 23), Q=> cw_execute, CLK=> CLK, RST=> RST, EN=>'1');

D_EN_WRITE_DECODE<=cw_execute(0);
E_EN_ZERO_REG<=cw_execute(1); E_EN_ALU_OUTPUT<=cw_execute(1);
E_EN_B_REG<=cw_execute(1); E_EN_C_REG<=cw_execute(1);
E_SEL_OP1_MUX<=cw_execute(2);
E_SEL_OP2_MUX<=cw_execute(3);    
E_ALU_FUNC(0)<=cw_execute(4); E_ALU_FUNC(1)<=cw_execute(5); 
E_ALU_FUNC(2)<=cw_execute(6); E_ALU_FUNC(3)<=cw_execute(7);
E_EN_COMPARATOR<=cw_execute(8); E_TYPE_OF_COMP<=cw_execute(9);
E_IS_JUMP<=cw_execute(10);

reg_2 : register_generic Generic Map (NBIT=> 8) Port Map (D(0)=>cw_execute(0), 
    D(1 to 6)=> cw_execute(11 to 16), D(7)=>cw_execute(10), Q=> cw_memory, CLK=> CLK, RST=> RST, EN=> '1');
    
M_EN_LMD_REG<=cw_memory(1); M_EN_ALU_OUTPUT<=cw_memory(1); M_EN_C_REG<=cw_memory(1);
M_EN_READ<=cw_memory(2);
M_EN_WRITE<=cw_memory(3);
M_IS_LINK<=cw_memory(4);
M_IS_JUMP<=cw_memory(7);
reg_3 : register_generic Generic Map (NBIT=> 3) Port Map (D(0)=>cw_memory(0), 
    D(1 to 2)=> cw_memory(5 to 6), Q=> cw_writeback, CLK=> CLK, RST=> RST, EN=> '1');
    
D_EN_WRITE<=cw_writeback(0);
W_EN_DATAPATH_OUT<=cw_writeback(1);
W_SEL_WB_MUX<=cw_writeback(2);
        
decode_instruction:process(D_OPCODE, D_FUNC, CLK)
begin
    case D_OPCODE is
        when "000000" => 
            case D_FUNC is
                when "00000000000" => control_word<="000000000000000000000000"; --all zeros, debug
                when "00000000100" => control_word<="111101101010110000100010";--sll --
                when "00000000110" => control_word<="111101101010111000100010";--srl
                when "00000100000" => control_word<="111101101010000000100010";--add
                when "00000100010" => control_word<="111101101010001000100010";--sub
                when "00000100100" => control_word<="111101101010011000100010";--and
                when "00000100101" => control_word<="111101101010100000100010";--or
                when "00000100110" => control_word<="111101101010101000100010";--xor
                when "00000101001" => control_word<="111101101011110000100010";--sne
                when "00000101100" => control_word<="111101101011101000100010";--sle
                when "00000101101" => control_word<="111101101011100000100010";--sge
                when OTHERS => control_word<="110000001001111000100010";--nop
            end case;
        when "000010" => control_word<="110010111001111001100010";--j
        when "000011" => control_word<="110011111110000001100110";--jal
        when "000100" => control_word<="111000011001111100100010";--beqz x
        when "000101" => control_word<="111000011001111110100010";--bnez x 
        when "001000" => control_word<="111001001000000000100010";--addi x
        when "001010" => control_word<="111001001000001000100010";--subi x
        when "001100" => control_word<="111001001000011000100010";--andi x 
        when "001101" => control_word<="111001001000100000100010";--ori  x
        when "001110" => control_word<="111001001000101000100010";--xori x 
        when "010100" => control_word<="111001001000110000100010";--slli x
        when "010101" => control_word<="110000001001111000100010";--nop 
        when "010110" => control_word<="111001001000111000100010";--srli x
        when "011001" => control_word<="111001001001110000100010";--snei x
        when "011100" => control_word<="111001001001101000100010";--slei x
        when "011101" => control_word<="111001001001100000100010";--sgei x
        when "100011" => control_word<="111101001000000000110011";--lw
        when "101011" => control_word<="111100001000000000101010";--sw x
        when OTHERS=> control_word<="110000001001111000100010";--nop
    end case;
end process decode_instruction;


end rtl;
