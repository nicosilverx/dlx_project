library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
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
signal control_word : std_logic_vector(0 to 21) := (OTHERS=>'0');
signal ex_to_mem : std_logic_vector(0 to 15) := (OTHERS=>'0');
signal mem_to_wb : std_logic_vector(0 to 6) := (OTHERS=>'0');

begin
--Decode
D_EN_RF <= control_word(0);
D_EN_READ1 <= control_word(1);
D_EN_READ2 <= control_word(2);
D_SEL_IMM_MUX <= control_word(3);
D_EN_A <= control_word(4); D_EN_B <= control_word(4); 
D_EN_C <= control_word(4); D_EN_IMM <= control_word(4); D_EN_NPC <= control_word(4);
D_SEL_RD_MUX <= control_word(6);

decode_execute_reg : register_generic Generic Map (NBIT=> 16) Port Map (D(0)=> control_word(5), D(1 to 15)=> control_word(7 to 21), Q=>ex_to_mem,
    CLK=>CLK, RST=>RST, EN=>'1');

--Execute
E_SEL_OP1_MUX <= ex_to_mem(1);
E_SEL_OP2_MUX <= ex_to_mem(2);
E_ALU_FUNC(0) <= ex_to_mem(3); 
E_ALU_FUNC(1) <= ex_to_mem(4); 
E_ALU_FUNC(2) <= ex_to_mem(5); 
E_ALU_FUNC(3) <= ex_to_mem(6);    
E_EN_NPC <= ex_to_mem(7); E_EN_ZERO_REG <= ex_to_mem(7); E_EN_ALU_OUTPUT <= ex_to_mem(7);
E_EN_B_REG <= ex_to_mem(7); E_EN_C_REG <= ex_to_mem(7);
E_EN_COMPARATOR <= ex_to_mem(8);
E_TYPE_OF_COMP <= ex_to_mem(9);

execute_memory_reg : register_generic Generic Map (NBIT=> 7) Port Map (D(0)=> ex_to_mem(0), D(1 to 6)=> ex_to_mem(10 to 15), Q=> mem_to_wb,
    CLK=>CLK, RST=>RST, EN=>'1');

--Memory
M_EN_READ <= mem_to_wb(1);
M_EN_WRITE <= mem_to_wb(2);
M_EN_LMD_REG <= mem_to_wb(3); M_EN_ALU_OUTPUT <= mem_to_wb(3); M_EN_C_REG <= mem_to_wb(3);
M_IS_LINK <= mem_to_wb(4);

memory_to_wb : register_generic Generic Map (NBIT=> 3) Port Map (D(0)=> mem_to_wb(0), D(1 to 2)=> mem_to_wb(5 to 6), 
    Q(0)=> D_EN_WRITE, Q(1)=> W_SEL_WB_MUX, Q(2)=> W_EN_DATAPATH_OUT, CLK=>CLK, RST=>RST, EN=>'1');

decode_instruction:process(D_OPCODE, D_FUNC)
begin
    case D_OPCODE is
        when "000000" => 
            case D_FUNC is
                when "00000000000" => control_word<="0000000000000000000000"; --all zeros, debug
                when "00000000100" => control_word<="1110111010110100001001";--sll
                when "00000000110" => control_word<="1110111011110100001001";--srl
                when "00000100000" => control_word<="1110111010000100001001";--add
                when "00000100010" => control_word<="1110111010001100001001";--sub
                when "00000100100" => control_word<="1110111011100100001001";--and
                when "00000100101" => control_word<="1110111010010100001001";--or
                when "00000100110" => control_word<="1110111011010100001001";--xor
                when "00000101001" => control_word<="1110111010111100001001";--sne
                when "00000101100" => control_word<="1110111011011100001001";--sle
                when "00000101101" => control_word<="1110111010011100001001";--sge
                when OTHERS => control_word<="0000100001111100001001";--nop
            end case;
        when "000010" => control_word<="0001101100000100001001";--j
        when "000011" => control_word<="0001111100000100001101";--jal
        when "000100" => control_word<="0001101100000110001001";--beqz
        when "000101" => control_word<="0001101100000111001001";--bnez
        when "001000" => control_word<="1100110000000100001001";--addi
        when "001010" => control_word<="1100110000001100001001";--subi
        when "001100" => control_word<="1100110001100100001001";--andi
        when "001101" => control_word<="1100110000010100001001";--ori
        when "001110" => control_word<="1100110001010100001001";--xori
        when "010100" => control_word<="1100110000110100001001";--slli
        when "010101" => control_word<="0000100001111100001001";--nop
        when "010110" => control_word<="1100110001110100001001";--srli
        when "011001" => control_word<="1100110000111100001001";--snei
        when "011100" => control_word<="1100110001011100001001";--slei
        when "011101" => control_word<="1100110000011100001001";--sgei
        when "100011" => control_word<="1100110000000100101011";--lw
        when "101011" => control_word<="1100100000000100011001";--sw
        when OTHERS=> control_word<="0000100001111100001001";--nop
    end case;
end process decode_instruction;


end rtl;
