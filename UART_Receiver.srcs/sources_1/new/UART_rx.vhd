library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity UART_rx is
generic(
	c_clokfreq : integer := 100_000_000;
	c_baudrate : integer := 115200
);
Port ( 
	clk 		 : in std_logic;
	rx_in   	 : in std_logic;
	d_out   	 : out std_logic_vector (7 downto 0);
	rx_done_tick : out std_logic
);
end UART_rx;

architecture Behavioral of UART_rx is

constant c_timerlim : integer := c_clokfreq/c_baudrate;

signal bittimer   : integer range 0 to c_timerlim := 0;
signal bitcounter : integer range 0 to 255 := 0;
signal tempreg    : std_logic_vector (7 downto 0) := (others => '0');

type state is (s_idle, s_start, s_data, s_stop);
signal rx_state : state := s_idle;

begin
process (clk) begin
	if(rising_edge(clk)) then
		case rx_state is
			when s_idle =>
				rx_done_tick <= '0';
				bittimer <= 0;
				tempreg <= x"00";
				if(rx_in = '0') then
					rx_state <= s_start;
				end if;
			when s_start =>
				if(bittimer = (c_timerlim/2)-1) then
					rx_state <= s_data;
					bittimer <= 0;
				else
					bittimer <= bittimer + 1;
				end if;
			when s_data =>
				if(bittimer = c_timerlim-1) then
					if(bitcounter = 8) then
						rx_state <= s_stop;
						bitcounter <= 0;
					else 
						bitcounter <= bitcounter+1;
					end if;
					tempreg <= rx_in & tempreg(7 downto 1);
					bittimer <= 0;
				else 
					bittimer <= bittimer + 1;
				end if;
			when s_stop =>
				if(bittimer <= c_timerlim) then
					rx_state <= s_idle;
					rx_done_tick <= '1';
				else 
					bittimer <= bittimer +1;
				end if;
		end case;
	end if;
end process;

d_out <= tempreg;

end Behavioral;
