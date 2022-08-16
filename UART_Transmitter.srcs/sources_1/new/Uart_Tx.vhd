library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity Uart_Tx is
generic(
	c_clockfreq   : integer := 100_000_000;
	c_baudrate    : integer := 115_200
);
port(
	clk			  : in std_logic;
	d_in 		  : in std_logic_vector(7 downto 0);
	tx_start_i	  : in std_logic;
	tx_o		  : out std_logic;
	tx_done_tick  : out std_logic
);
end Uart_Tx;

architecture Behavioral of Uart_Tx is

constant c_timelim : integer := c_clockfreq/c_baudrate;

signal bittimer    : integer := 0;
signal tempreg     : std_logic_vector (7 downto 0) := (others => '0');
signal bitcounter  : integer := 0;

type state is ( s_idle, s_start, s_data, s_stop);
signal Tx_state : state := s_idle;

begin
process (clk) begin 
	if(rising_edge(clk)) then
		
		case Tx_state is
			
			when s_idle  =>	
			tx_o <= '1';
            tx_done_tick <= '0';			
			bittimer <= 0;
			if(tx_start_i = '1') then
				Tx_state <= s_start;
				tx_o <= '0';
				tempreg <= d_in;
			end if;
			
			when s_start =>
				if(bittimer = c_timelim-1) then
					Tx_state <= s_data;
					bittimer <= 0;
					--tempreg(7)			<= tempreg(0);
					--tempreg(6 downto 0)	<= tempreg(7 downto 1);
				else 
					bittimer <= bittimer + 1;
				end if;
			when s_data  =>
				if(bitcounter = 8) then
					if(bittimer = c_timelim-1) then
						Tx_state <= s_stop;
						tx_o     <= tempreg(0);
						tempreg  <= '0' & tempreg(7 downto 1);
						tx_done_tick <= '1';
						bittimer <= 0;
					else 
						bittimer <= bittimer + 1;
					end if;
				else
					if(bittimer = c_timelim-1) then
						tx_o <= tempreg(0);
						tempreg  <= '0' & tempreg(7 downto 1);
						bitcounter <= bitcounter + 1;
						bittimer <= 0;
					else 
						bittimer <= bittimer + 1;
					end if;
					
				end if;
			
			when s_stop  =>
				if(bittimer = c_timelim-1) then
					tx_o <= '1';
					bittimer   <= 0;
					bitcounter <= 0;
					tx_done_tick <= '1';
					Tx_state <= s_idle;
				else
					bittimer <= bittimer + 1;
				end if;
		end case;
	end if;
end process;

end Behavioral;
