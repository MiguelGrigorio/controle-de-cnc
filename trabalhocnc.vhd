library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity trabalhocnc is
	port (
		reset_n : in std_logic;
		BA_n    : in std_logic;
		BB_n    : in std_logic;
		BC_n    : in std_logic;
		clock   : in std_logic;
		wiresX  : out std_logic_vector(3 downto 0);
		wiresY  : out std_logic_vector(3 downto 0);
		rx      : in std_logic;
		laser   : out std_logic
	);
end trabalhocnc;

architecture behavioral of trabalhocnc is

	type states is (Points, Buttons, A0, A1, A2, A3, A4, A5, B0, B1, B2, B3, B4, B5, C);
	signal state, next_state : states;

	-- UART:
	signal X0, Y0, X1, Y1, X2, Y2, X3, Y3, X, Y                   : integer range 0 to 9;
	signal Xp, Yp                                                 : integer range 0 to 6579; -- steps
	signal data0, data1, data2, data3, data4, data5, data6, data7 : std_logic_vector(7 downto 0);
	signal validData                                              : std_logic;

	-- not buttons
	signal reset, BA, BB, BC : std_logic;

	signal resetTimer                             : std_logic;
	signal timerOvf                               : std_logic;
	signal motorX, motorY, directionX, directionY : std_logic;
	signal stepsX, stepsY                         : integer range 0 to 6579;
	signal esquerda, direita, cima, baixo         : std_logic;


begin

	--- UART:
	--Data0: 000 0 X0(4bits)
	--Data1: 001 0 Y0(4bits)
	--Data2: 010 0 X1(4bits)
	--Data3: 011 0 Y1(4bits)
	--Data4: 100 0 X2(4bits)
	--Data5: 101 0 Y2(4bits)
	--Data6: 110 0 X3(4bits)
	--Data7: 111 0 Y3(4bits)
	uart1 : entity work.uart_module port map (
		clock     => clock,
		reset     => reset,
		rx        => rx,
		data0     => data0,
		data1     => data1,
		data2     => data2,
		data3     => data3,
		data4     => data4,
		data5     => data5,
		data6     => data6,
		data7     => data7,
		validData => validData
		);

	process (reset, clock)
	begin
		if reset = '1' then
			X0 <= 0;
			Y0 <= 0;
			X1 <= 0;
			Y1 <= 0;
			X2 <= 0;
			Y2 <= 0;
			X3 <= 0;
			Y3 <= 0;
		elsif rising_edge(clock) then
			if validData = '1' and state = Points then
				X0 <= to_integer(unsigned(data0(3 downto 0)));
				Y0 <= to_integer(unsigned(data1(3 downto 0)));
				X1 <= to_integer(unsigned(data2(3 downto 0)));
				Y1 <= to_integer(unsigned(data3(3 downto 0)));
				X2 <= to_integer(unsigned(data4(3 downto 0)));
				Y2 <= to_integer(unsigned(data5(3 downto 0)));
				X3 <= to_integer(unsigned(data6(3 downto 0)));
				Y3 <= to_integer(unsigned(data7(3 downto 0)));
			end if;
		end if;
	end process;

	-- Logica de pontos para steps
process(state, X0, X1, X2, X3, Y0, Y1, Y2, Y3)
begin
	case state is
		when A0 =>
		
			X <= X0;
			Y <= Y0;
		when A1 =>
		
			X <= X1;
			Y <= Y1;
		when A2 =>
		
			X <= X2;
			Y <= Y2;
		when A3 =>
		
			X <= X3;
			Y <= Y3;
		when A4 =>
		
			X <= X1;
			Y <= Y1;
		when A5 =>
		
			X <= X0;
			Y <= Y0;
		when B0 => 
		
			X <= X0;
			Y <= Y0;
		when B1 =>
		
			if X1 <= X2 and X1 <= X3 then
				X <= X1;
			elsif X2 <= X1 and X2 <= X3 then
				X <= X2;
			else 
				X <= X3;
			end if;
			
			if Y1 <= Y2 and Y1 <= Y3 then
				Y <= Y1;
			elsif Y2 <= Y1 and Y2 <= Y3 then
				Y <= Y2;
			else 
				Y <= Y3;
			end if;
		when B2 =>
		
			if X1 >= X2 and X1 >= X3 then
				X <= X1;
			elsif X2 >= X1 and X2 >= X3 then
				X <= X2;
			else 
				X <= X3;
			end if;
			
			if Y1 <= Y2 and Y1 <= Y3 then
				Y <= Y1;
			elsif Y2 <= Y1 and Y2 <= Y3 then
				Y <= Y2;
			else 
				Y <= Y3;
			end if;
		when B3 =>
		
			if X1 >= X2 and X1 >= X3 then
				X <= X1;
			elsif X2 >= X1 and X2 >= X3 then
				X <= X2;
			else 
				X <= X3;
			end if;
			
			if Y1 >= Y2 and Y1 >= Y3 then
				Y <= Y1;
			elsif Y2 >= Y1 and Y2 >= Y3 then
				Y <= Y2;
			else 
				Y <= Y3;
			end if;
		when B4 =>
		
			if X1 <= X2 and X1 <= X3 then
				X <= X1;
			elsif X2 <= X1 and X2 <= X3 then
				X <= X2;
			else 
				X <= X3;
			end if;
			
			if Y1 >= Y2 and Y1 >= Y3 then
				Y <= Y1;
			elsif Y2 >= Y1 and Y2 >= Y3 then
				Y <= Y2;
			else 
				Y <= Y3;
			end if;
		when others =>
		
			if X1 <= X2 and X1 <= X3 then
				X <= X1;
			elsif X2 <= X1 and X2 <= X3 then
				X <= X2;
			else 
				X <= X3;
			end if;
			
			if Y1 <= Y2 and Y1 <= Y3 then
				Y <= Y1;
			elsif Y2 <= Y1 and Y2 <= Y3 then
				Y <= Y2;
			else 
				Y <= Y3;
			end if;
		
end case;
end process;
	with X select Xp <=
		0 when 0,
		731 when 1,
		1462 when 2,
		2193 when 3,
		2924 when 4,
		3655 when 5,
		4386 when 6,
		5117 when 7,
		5848 when 8,
		6579 when others;


	with Y select Yp <=
		0 when 0,
		731 when 1,
		1462 when 2,
		2193 when 3,
		2924 when 4,
		3655 when 5,
		4386 when 6,
		5117 when 7,
		5848 when 8,
		6579 when others;
	-- Controle da direcao
	esquerda <= '0';
	direita  <= '1';
	cima     <= '1';
	baixo    <= '0';

	-- not buttons
	reset <= not reset_n;
	BA    <= not BA_n;
	BB    <= not BB_n;
	BC    <= not BC_n;

	-- Entitys
	timer2sec : entity work.timer port map (
		clock    => clock,
		reset    => resetTimer,
		period   => 99_999_999,
		overflow => timerOvf
		);

	mtrY : entity work.motor port map (
		clock     => clock,
		reset     => reset,
		direction => directionY,
		enable    => motorY,
		wires     => wiresY,
		step      => stepsY
		);

	mtrX : entity work.motor port map (
		clock     => clock,
		reset     => reset,
		direction => directionX,
		enable    => motorX,
		wires     => wiresX,
		step      => stepsX
		);

	-- Passar os estados
	process (reset, clock)
	begin
		if reset = '1' then
			state <= Points;
		elsif rising_edge(clock) then
			state <= next_state;
		end if;
	end process;

	-- Logica de proximo estado
	process (state, validData, BA, BB, BC, stepsX, Xp, stepsY, Yp, timerOvf)
	begin
		case state is
			when Points =>

				if validData = '1' then
					next_state <= Buttons;
				else
					next_state <= Points;
				end if;

			when Buttons =>

				if BA = '1' then
					next_state <= A0;
				elsif BB = '1' then
					next_state <= B0;
				elsif BC = '1' then
					next_state <= C;
				else
					next_state <= Buttons;
				end if;

			when A0 =>

				if stepsX = Xp and stepsY = Yp then
					next_state <= A1;
				else
					next_state <= A0;
				end if;

			when A1 =>

				if stepsX = Xp and stepsY = Yp and timerOvf = '1' then
					next_state <= A2;
				else
					next_state <= A1;
				end if;

			when A2 =>

				if stepsX = Xp and stepsY = Yp then
					next_state <= A3;
				else
					next_state <= A2;
				end if;

			when A3 =>

				if stepsX = Xp and stepsY = Yp then
					next_state <= A4;
				else
					next_state <= A3;
				end if;

			when A4 =>

				if stepsX = Xp and stepsY = Yp then
					next_state <= A5;
				else
					next_state <= A4;
				end if;

			when A5 => -- Completou A

				if stepsX = Xp and stepsY = Yp then
					next_state <= Buttons;
				else
					next_state <= A5;
				end if;
			when B0 =>

				if stepsX = Xp and stepsY = Yp then
					next_state <= B1;
				else
					next_state <= B0;
				end if;

			when B1 =>

				if stepsX = Xp and stepsY = Yp then
					next_state <= B2;
				else
					next_state <= B1;
				end if;

			when B2 =>

				if stepsX = Xp and stepsY = Yp then
					next_state <= B3;
				else
					next_state <= B2;
				end if;

			when B3 =>

				if stepsX = Xp and stepsY = Yp then
					next_state <= B4;
				else
					next_state <= B3;
				end if;

			when B4 =>

				if stepsX = Xp and stepsY = Yp then
					next_state <= B5;
				else
					next_state <= B4;
				end if;

			when B5 => -- Completou B

				if stepsX = Xp and stepsY = Yp then
					next_state <= Buttons;
				else
					next_state <= B5;
				end if;

			when C =>

				next_state <= Points;

		end case;
	end process;

	-- Logica dos motores
	process (state, stepsX, Xp, stepsY, Yp, esquerda, direita, cima, baixo, motorX)
	begin
		if state /= Points and state /= C and state /= Buttons then
			if stepsX = Xp then
				motorX     <= '0';
				directionX <= '0';
			else
				motorX <= '1';
				if stepsX < Xp then
					directionX <= direita;
				else
					directionX <= esquerda;
				end if;
			end if;

			if stepsY = Yp then
				motorY     <= '0';
				directionY <= '0';
			else
				motorY <= '1';
				if stepsY < Yp then
					directionY <= cima;
				else
					directionY <= baixo;
				end if;
			end if;
		else
			motorX     <= '0';
			directionX <= '0';
			motorY     <= '0';
			directionY <= '0';
		end if;
	end process;

	-- Logica de saida
	process (state)
	begin
		case state is

			when A1 =>

				laser      <= '0';
				resetTimer <= '0';

			when A2 =>

				laser      <= '1';
				resetTimer <= '1';

			when A3 =>

				laser      <= '1';
				resetTimer <= '1';

			when A4 =>

				laser      <= '1';
				resetTimer <= '1';
				
			when others =>

				laser      <= '0';
				resetTimer <= '1';


		end case;
	end process;

end behavioral;
