library ieee;
use ieee.std_logic_1164.all;

entity timer is
	port (
		clock    : in std_logic;
		reset    : in std_logic;
		period   : in integer;
		overflow : out std_logic
	);
end timer;

architecture behavioral of timer is
	signal count, NextCount : integer;
begin

	NextCount <= 1 when count = period else
		count + 1;

	process (clock, reset)
	begin
		if reset = '1' then
			count <= 1;
		elsif rising_edge(clock) then
			count <= NextCount;
		end if;
	end process;

	overflow <= '1' when count = period else
		'0';

end behavioral;