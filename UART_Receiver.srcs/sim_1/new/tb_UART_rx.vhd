library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity tb_UART_rx is
generic(
	c_clokfreq : integer := 100_000_000;
	c_baudrate : integer := 115200
);
end tb_UART_rx;


architecture Behavioral of tb_UART_rx is

component UART_rx is
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
end component;

signal  clk 		 : std_logic := '0';
signal  rx_in   	 : std_logic := '0';
signal  d_out   	 : std_logic_vector (7 downto 0);
signal  rx_done_tick : std_logic;

constant c_clkperiod : time := 10ns;
constant c_hex43 	 : std_logic_vector (9 downto 0) := '1' & x"43" & '0';
constant c_hexA5 	 : std_logic_vector (9 downto 0) := '1' & x"A5" & '0';
constant c_baud115200	: time := 8.68 us;

begin

DUT : UART_rx
generic map(
	c_clokfreq => c_clokfreq,
	c_baudrate => c_baudrate
)
Port map( 
	clk 		 => clk 		  ,
	rx_in   	 => rx_in   	  ,
	d_out   	 => d_out   	  ,
	rx_done_tick => rx_done_tick 
);

P_clock : process begin 
clk	<= '0';
wait for c_clkperiod/2;
clk	<= '1';
wait for c_clkperiod/2;
end process P_clock;

P_STIMULI : process begin

wait for c_clkperiod*10;

for i in 0 to 9 loop
	rx_in <= c_hex43(i);
	wait for c_baud115200;
end loop;

wait for 10 us;

for i in 0 to 9 loop
	rx_in <= c_hexA5(i);
	wait for c_baud115200;
end loop; 

wait for 20 us;

assert false
report "SIM DONE"
severity failure;

end process P_STIMULI;


end Behavioral;
