library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_module is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           rx : in  STD_LOGIC;
			  data0 : out  STD_LOGIC_VECTOR (7 downto 0);
           data1 : out  STD_LOGIC_VECTOR (7 downto 0);
           data2 : out  STD_LOGIC_VECTOR (7 downto 0);
           data3 : out  STD_LOGIC_VECTOR (7 downto 0);
           data4 : out  STD_LOGIC_VECTOR (7 downto 0);
           data5 : out  STD_LOGIC_VECTOR (7 downto 0);
           data6 : out  STD_LOGIC_VECTOR (7 downto 0);
           data7 : out  STD_LOGIC_VECTOR (7 downto 0);
           validData : out  STD_LOGIC);
end uart_module;

architecture Behavioral of uart_module is
signal dados : STD_LOGIC_VECTOR (7 downto 0);
signal state : integer;
signal dataReady : STD_LOGIC;

begin

uart1: entity work.uart_core port map
			( clock 	=> clock,
           reset 	=> reset,
           rx 		=> rx,
			  data 	=> dados,
			  dataReady => dataReady);

-- Receiving
process(clock, reset)
begin
if reset = '1' then
	data0 <= (others => '0');
	data1 <= (others => '0');
	data2 <= (others => '0');
	data3 <= (others => '0');
	data4 <= (others => '0');
	data5 <= (others => '0');
	data6 <= (others => '0');
	data7 <= (others => '0');
	state <= 0;
elsif rising_edge(clock) then
	validData <= '0';
	if dataReady = '1' then
		case state is
		when 0 =>
			if dados(7 downto 5) = "000" then
				data0 <= dados;
				state <= state + 1;
			else
				state <= 0;
			end if;
		when 1 =>
			if dados(7 downto 5) = "001" then
				data1 <= dados;
				state <= state + 1;
			else
				state <= 1;
			end if;
		when 2 =>
			if dados(7 downto 5) = "010" then
				data2 <= dados;
				state <= state + 1;
			else
				state <= 2;
			end if;
		when 3 =>
			if dados(7 downto 5) = "011" then
				data3 <= dados;
				state <= state + 1;
			else
				state <= 3;
			end if;
		when 4 =>
			if dados(7 downto 5) = "100" then
				data4 <= dados;
				state <= state + 1;
			else
				state <= 4;
			end if;
		when 5 =>
			if dados(7 downto 5) = "101" then
				data5 <= dados;
				state <= state + 1;
			else
				state <= 5;
			end if;
		when 6 =>
			if dados(7 downto 5) = "110" then
				data6 <= dados;
				state <= state + 1;
			else
				state <= 6;
			end if;
		when 7 =>
			if dados(7 downto 5) = "111" then
				data7 <= dados;
				validData <= '1';
				state <= 0;
			else
				state <= 7;
			end if;
		when others =>
			state <= 0;
		end case;
	end if;
end if;
end process;

end Behavioral;
