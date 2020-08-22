library ieee;
use ieee.std_logic_1164.all;
use WORK.constants.all;

entity mux21 is
  --Defining the generics for the multiplexer
  Port (  A:    in	std_logic_vector(0 to NUMBIT-1) ;
	        B:	  in	std_logic_vector(0 to NUMBIT-1);
          SEL:	in	std_logic;
          Y:	  out	std_logic_vector(0 to NUMBIT-1));
end mux21;

--First architecture describes behaviourally a MUX 2 to 1
--If S=0, output is A, else if S=1, output is B
architecture mux21_rt of mux21 is
  begin
    bmux:process(A,B,SEL)
    begin
      if (SEL='0') then 
        Y <= A;
      else 
        Y <= B;
      end if;
    end process bmux;
end mux21_rt;



