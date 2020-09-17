library ieee;
use ieee.std_logic_1164.all;

package constants is

-- DLX general constants
	constant NUMBIT		  : integer := 32;
	constant ADDRBIT	  : integer := 5;
	constant NUMRF		  : integer := 32;
-- Control unit input sizes
	constant OP_CODE_SIZE : integer := 6;
	constant FUNC_SIZE	  : integer := 11;

end constants;