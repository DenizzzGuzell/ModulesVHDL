
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity tb_UART_tx is
generic(
	c_clockfreq   : integer := 100_000_000;
	c_baudrate    : integer := 115200
);
end tb_UART_tx;

architecture Behavioral of tb_UART_tx is

component Uart_Tx is
generic(
	c_clockfreq   : integer := 100_000_000;
	c_baudrate    : integer := 115200
);
port(
	clk			  : in std_logic;
	d_in 		  : in std_logic_vector(7 downto 0);
	tx_start_i	  : in std_logic;
	tx_o		  : out std_logic;
	tx_done_tick  : out std_logic
);
end component;

signal clk			   : std_logic := '0';
signal d_in 		   : std_logic_vector (7 downto 0) := (others =>'0');
signal tx_start_i	   : std_logic := '0';
signal tx_o		       : std_logic;
signal tx_done_tick    : std_logic;

constant c_clkperiod : time := 10ns;

begin

DUT : uart_tx
generic map(
c_clockfreq 		=> c_clockfreq 	  ,
c_baudrate  		=> c_baudrate  	  
)
port map(
clk			  => clk	         ,
d_in 		  => d_in 		     ,
tx_start_i	  => tx_start_i	     ,
tx_o		  => tx_o		         ,
tx_done_tick  => tx_done_tick  	
);


P_CLKGEN : process begin

clk	<= '0';
wait for c_clkperiod/2;
clk	<= '1';
wait for c_clkperiod/2;

end process P_CLKGEN;

P_STIMULI : process begin

d_in			<= x"00";
tx_start_i		<= '0';

wait for c_clkperiod*10;

d_in		<= x"A3";
tx_start_i	<= '1';
wait for c_clkperiod;
tx_start_i	<= '0';

wait until (rising_edge(tx_done_tick));

wait for 1 us;

assert false
report "SIM DONE"
severity failure;


end process P_STIMULI;
end Behavioral;
