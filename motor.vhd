library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity motor is
	port (
		clock     : in std_logic;                     --	Tic Tac
		reset     : in std_logic;                     -- 	Chave para reiniciar
		direction : in std_logic;                     -- 	Horário ou anti-horário
		enable    : in std_logic;                     -- 	Pode realizar o movimento ou não
		wires     : out std_logic_vector(3 downto 0); -- 	Bobinas motor
		step      : out integer						  --    Steps atuais
	);
end motor;

architecture behavioral of motor is

	type state_t is (Blue, BluePink, Pink, PinkYellow, Yellow, YellowOrange, Orange, OrangeBlue); -- Define nomes dos estados
	signal state, next_state : state_t;
	signal ovf               : std_logic;
	signal steps             : integer range 0 to 6579;

begin

	process (state, direction)
	begin
		if direction = '0' then
			case state is
				when Blue         => next_state     <= BluePink;
				when BluePink     => next_state     <= Pink;
				when Pink         => next_state     <= PinkYellow;
				when PinkYellow   => next_state   	<= Yellow;
				when Yellow       => next_state     <= YellowOrange;
				when YellowOrange => next_state 	<= Orange;
				when Orange       => next_state     <= OrangeBlue;
				when OrangeBlue   => next_state   	<= Blue;
			end case;
		else -- direction = '1'
			case state is
				when Blue         => next_state    	<= OrangeBlue;
				when BluePink     => next_state     <= Blue;
				when Pink         => next_state     <= BluePink;
				when PinkYellow   => next_state   	<= Pink;
				when Yellow       => next_state     <= PinkYellow;
				when YellowOrange => next_state		<= Yellow;
				when Orange       => next_state     <= YellowOrange;
				when OrangeBlue   => next_state   	<= Orange;
			end case;
		end if;
	end process;

	-- Flip Flop
	process (clock, reset)
	begin
		if reset = '1' then
			state <= Blue;
			step  <= 0;
		elsif rising_edge(clock) then
			step <= steps;
			if ovf = '1' and enable = '1' then
				state <= next_state;
				if direction = '1' then
					steps <= steps + 1;
				else
					steps <= steps - 1;
				end if;
			end if;
		end if;
	end process;

	with state select
		wires <= "1000" when Blue,
		"0100" when Pink,
		"0010" when Yellow,
		"0001" when Orange,
		"1100" when BluePink,
		"0110" when PinkYellow,
		"0011" when YellowOrange,
		"1001" when OrangeBlue,
		"0000" when others;

	timer : entity work.timer port map (
		clock    => clock,
		reset    => reset,
		period   => 185_185,
		overflow => ovf
		);

end behavioral;