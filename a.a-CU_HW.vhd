library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
--use ieee.numeric_std.all;
--use work.all;

entity dlx_cu is
  generic (
    FUNC_SIZE          :     integer := 11;  -- Func Field Size for R-Type Ops
    OP_CODE_SIZE       :     integer := 6;  -- Op Code Size
    IR_SIZE            :     integer := 32;  -- Instruction Register Size    
    CW_SIZE            :     integer := 15);  -- Control Word Size
  port (
    IR_IN : in std_logic_vector(0 to 31);
    D_OPCODE : in std_logic_vector(0 to 5);
          D_FUNC : in std_logic_vector(0 to 10);
          CLK, RST : in std_logic;
          D_EN_RF, D_EN_READ1, D_EN_READ2, D_SEL_IMM_MUX, 
          D_EN_A, D_EN_B, D_EN_C, D_EN_IMM, D_EN_NPC, D_EN_WRITE, D_SEL_RD_MUX, D_IS_JUMP : out std_logic;
          E_SEL_OP1_MUX, E_SEL_OP2_MUX : out std_logic;
          E_ALU_FUNC : out std_logic_vector(0 to 3);
          E_EN_ZERO_REG, E_EN_ALU_OUTPUT,
          E_EN_B_REG, E_EN_C_REG, E_EN_COMPARATOR, E_TYPE_OF_COMP, E_IS_JUMP : out std_logic;
          M_EN_READ, M_EN_WRITE, M_EN_LMD_REG, M_EN_ALU_OUTPUT, M_EN_C_REG, M_IS_LINK : out std_logic;
          W_SEL_WB_MUX, W_EN_DATAPATH_OUT : out std_logic);  -- Register File Write Enable

end dlx_cu;

architecture dlx_cu_hw of dlx_cu is                     

  signal IR_opcode : std_logic_vector(0 to 5);  -- OpCode part of IR
  signal IR_func : std_logic_vector(0 to 10);   -- Func part of IR when Rtype
  signal cw   : std_logic_vector(0 to 23); -- full control word read from cw_mem
  signal cw1   : std_logic_vector(0 to 23);
  signal cw2 : std_logic_vector(0 to 16) := (OTHERS=>'0'); --17 control signals
  signal cw3 : std_logic_vector(0 to 6) := (OTHERS=>'0'); --7 control signals
  signal cw4 : std_logic_vector(0 to 2) := (OTHERS=>'0');

  -- control word is shifted to the correct stage
  --signal cw1 : std_logic_vector(CW_SIZE -1 downto 0); -- first stage
  --signal cw2 : std_logic_vector(CW_SIZE - 1 - 2 downto 0); -- second stage
  --signal cw3 : std_logic_vector(CW_SIZE - 1 - 5 downto 0); -- third stage
  --signal cw4 : std_logic_vector(CW_SIZE - 1 - 9 downto 0); -- fourth stage
  --signal cw5 : std_logic_vector(CW_SIZE -1 - 13 downto 0); -- fifth stage

  --signal aluOpcode_i: aluOp := NOP; -- ALUOP defined in package
  --signal aluOpcode1: aluOp := NOP;
  --signal aluOpcode2: aluOp := NOP;
  --signal aluOpcode3: aluOp := NOP;


 
begin  -- dlx_cu_rtl

  IR_opcode(0 to 5) <= IR_IN(0 to 5);
  IR_func(0 to 10)  <= IR_IN(21 to 31);

  -- stage one control signals
  D_EN_A<=cw1(0); D_EN_B<=cw1(0); 
D_EN_C<=cw1(0); D_EN_IMM<=cw1(0); D_EN_NPC<=cw1(0);
D_EN_RF<=cw1(1);
D_EN_READ1<=cw1(2);
D_EN_READ2<=cw1(3);
D_SEL_IMM_MUX<=cw1(4);--(5) is D_EN_WRITE
D_SEL_RD_MUX<=cw1(6);
D_IS_JUMP<=cw1(7);
  
  -- stage two control signals
  E_EN_ZERO_REG<=cw2(1); E_EN_ALU_OUTPUT<=cw2(1);
E_EN_B_REG<=cw2(1); E_EN_C_REG<=cw2(1);
E_SEL_OP1_MUX<=cw2(2);
E_SEL_OP2_MUX<=cw2(3);    
E_ALU_FUNC(0)<=cw2(4); E_ALU_FUNC(1)<=cw2(5); 
E_ALU_FUNC(2)<=cw2(6); E_ALU_FUNC(3)<=cw2(7);
E_EN_COMPARATOR<=cw2(8); E_TYPE_OF_COMP<=cw2(9);
E_IS_JUMP<=cw2(10);
  
  -- stage three control signals
  M_EN_LMD_REG<=cw3(1); M_EN_ALU_OUTPUT<=cw3(1); M_EN_C_REG<=cw3(1);
M_EN_READ<=cw3(2);
M_EN_WRITE<=cw3(3);
M_IS_LINK<=cw3(4);
  
  -- stage four control signals
  D_EN_WRITE<=cw4(0);
W_EN_DATAPATH_OUT<=cw4(1);
W_SEL_WB_MUX<=cw4(2);
  
  -- stage five control signals


  -- process to pipeline control words
  CW_PIPE: process (Clk, Rst)
  begin  -- process Clk
    if Rst = '0' then                   -- asynchronous reset (active low)
      cw1 <= (others => '0');
      cw2 <= (others => '0');
      cw3 <= (others => '0');
      cw4 <= (others => '0');
      --cw5 <= (others => '0');
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      cw1 <= cw;
      cw2(0) <= cw1(5); cw2(1 to 16)<=cw1(8 to 23);
      cw3(0) <= cw2(0); cw3(1 to 6)<= cw2(11 to 16);
      cw4(0) <= cw3(0); cw4(1 to 2)<=cw3(5 to 6);

    end if;
  end process CW_PIPE;


decode_instruction:process(D_OPCODE, D_FUNC)
begin
    case D_OPCODE is
        when "000000" => 
            case D_FUNC is
                when "00000000000" => cw<="000000000000000000000000"; --all zeros, debug
                when "00000000100" => cw<="111101101010110000100010";--sll --
                when "00000000110" => cw<="111101101010111000100010";--srl
                when "00000100000" => cw<="111101101010000000100010";--add
                when "00000100010" => cw<="111101101010001000100010";--sub
                when "00000100100" => cw<="111101101010011000100010";--and
                when "00000100101" => cw<="111101101010100000100010";--or
                when "00000100110" => cw<="111101101010101000100010";--xor
                when "00000101001" => cw<="111101101011110000100010";--sne
                when "00000101100" => cw<="111101101011101000100010";--sle
                when "00000101101" => cw<="111101101011100000100010";--sge
                when OTHERS => cw<="110000001001111000100010";--nop
            end case;
        when "000010" => cw<="110010111100000001100010";--j
        when "000011" => cw<="110011111100000001100110";--jal
        when "000100" => cw<="110010101100000100100010";--beqz
        when "000101" => cw<="110010101100000110100010";--bnez
        when "001000" => cw<="111001001000000000100010";--addi
        when "001010" => cw<="111001001000001000100010";--subi
        when "001100" => cw<="111001001000011000100010";--andi
        when "001101" => cw<="111001001000100000100010";--ori
        when "001110" => cw<="111001001000101000100010";--xori
        when "010100" => cw<="111001001000110000100010";--slli
        when "010101" => cw<="110000001001111000100010";--nop
        when "010110" => cw<="111001001000111000100010";--srli
        when "011001" => cw<="111001001001110000100010";--snei
        when "011100" => cw<="111001001001101000100010";--slei
        when "011101" => cw<="111001001001100000100010";--sgei
        when "100011" => cw<="111101001000000000110011";--lw
        when "101011" => cw<="111100001000000000101010";--sw
        when OTHERS=> cw<="110000001001111000100010";--nop
    end case;
end process decode_instruction;


end dlx_cu_hw;
