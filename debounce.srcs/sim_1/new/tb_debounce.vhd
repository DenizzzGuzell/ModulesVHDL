library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity tb_debounce is
generic(
	c_clkfreq  : integer := 100_000_000;
	c_debtime : integer := 1000;
	c_initval  : std_logic := '0'	
);
end tb_debounce;

architecture Behavioral of tb_debounce is

component debounce is
generic(
c_clkfreq  : integer := 100_000_000; 
c_debtime : integer := 1000;
c_initval  : std_logic := '0'
);
Port (
clk				: in std_logic;
signal_i		: in std_logic;
signal_o		: out std_logic
 );
end component;

signal clk      : std_logic := '0';
signal signal_i : std_logic := '0';
signal signal_o : std_logic;

constant c_clkperiod : time := 10ns;

begin

DUT : debounce
generic map(
	c_clkfreq  => c_clkfreq, 
    c_debtime  => c_debtime,
    c_initval  => c_initval
)              
port map (     
	clk		   => clk,
    signal_i   => signal_i,
    signal_o   => signal_o
);             

p_clk : process begin 
	clk <= '0';
	wait for c_clkperiod/2;
	clk <= '1';
	wait for c_clkperiod/2;
end process;

p_stimule : process begin 
	signal_i <= '0';
	wait for 2 ms;
	
	signal_i <= '1';
	wait for 0.8 ms;
	signal_i <= '0';
	wait for 0.1 ms;
	signal_i <= '1';
	wait for 0.2 ms;
	signal_i <= '0';
	wait for 0.5 ms;
	signal_i <= '1';
	wait for 0.7 ms;
	signal_i <= '0';
	wait for 0.05 ms;
	signal_i <= '1';
	wait for 1 ms;
	
	signal_i <= '0';
	wait for 0.2 ms;
	signal_i <= '1';
	wait for 0.4 ms;
	signal_i <= '0';
	wait for 0.6 ms;
	signal_i <= '1';
	wait for 0.1 ms;
	signal_i <= '0';
	wait for 0.1 ms;
	signal_i <= '1';
	wait for 0.01 ms;
	signal_i <= '0';
	wait for 0.06 ms;
	signal_i <= '1';
	wait for 0.9 ms;
	signal_i <= '0';
	wait for 2 ms;
	
	assert false report "Sim Done" severity failure;
end process;

end Behavioral;
