library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_core is
	 generic ( baudRate : integer := 9600
	 );
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           rx : in  STD_LOGIC;
           data : out  STD_LOGIC_VECTOR (7 downto 0);
           dataReady : out  STD_LOGIC);
end uart_core;

architecture Behavioral of uart_core is
-- States
type states is (idle, startBit, dataBit, stopBit, cleanup);
signal state : states;

-- Baudrate
signal halfBitTime : integer;
signal bitTime : integer;
signal clockCount : integer;
signal bitIndex : integer;

-- Double register
signal rx_data, rx_data_R : std_logic;

-- Data
signal rxByte : std_logic_vector(7 downto 0);

begin

-- Bit times
with baudRate select
halfBitTime <= 2599 when 9600,
					1301 when 19200,
					2599 when others;
with baudRate select
bitTime <= 5199 when 9600,
			  2603 when 19200,
			  5199 when others;
			
-- Double register the incoming data
process(clock, reset)
begin
if reset = '1' then
	rx_data <= '1';
	rx_data_R <= '1';
elsif rising_edge(clock) then
	rx_data_R <= rx;
	rx_data <= rx_data_R;
end if;
end process;
			
-- State logic
process(clock, reset)
begin
if reset = '1' then
	state <= idle;
	dataReady <= '0';
	clockCount <= 0;
	bitIndex <= 0;
	rxByte <= (others=>'0');
elsif rising_edge(clock) then
	case state is
		when idle =>
			dataReady <= '0';
			clockCount <= 0;
			bitIndex <= 0;
			
			if rx_data = '0' then
				state <= startBit;
			--else
				--state <= idle;
			end if;
			
		when startBit =>
			if clockCount = halfBitTime then
				if rx_data = '0' then
					clockCount <= 0;
					state <= dataBit;
				else
					state <= idle;
				end if;
			else
				clockCount <= clockCount + 1;
				--state <= startBit;
			end if;
			
		when dataBit =>
			if clockCount < bitTime then
				clockCount <= clockCount + 1;
				--state <= dataBit;
			else
				clockCount <= 0;
				rxByte(bitIndex) <= rx_data;
				
				if bitIndex < 7 then
					bitIndex <= bitIndex + 1;
					--state <= dataBit;
				else
					bitIndex <= 0;
					state <= stopBit;
				end if;
			end if;
			
		when stopBit =>
			if clockCount < bitTime then
				clockCount <= clockCount + 1;
				--state <= stopBit;
			else
				dataReady <= '1';
				--data <= rxByte;
				clockCount <= 0;
				state <= cleanup;
			end if;
		when cleanup =>
			dataReady <= '0';
			state <= idle;
		when others =>
			state <= idle;
	end case;
end if;
end process;

-- Output
data <= rxByte;

end Behavioral;
