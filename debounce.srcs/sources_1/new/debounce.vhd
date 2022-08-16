library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity debounce is
generic(
c_clkfreq  : integer := 100_000_000; --board clock freq in nexys 4 ddr it is 100 mHz
c_debtime : integer := 1000; --1 ms for checking signal
c_initval  : std_logic := '0'
);
Port (
clk				: in std_logic;
signal_i		: in std_logic;
signal_o		: out std_logic
 );
end debounce;

architecture Behavioral of debounce is

constant c_timerlim   : integer := c_clkfreq/c_debtime; 

signal timer          : integer range 0 to c_timerlim := 0;
signal timer_en       : std_logic := '0';
signal timer_tick     : std_logic := '0';

type t_state is (s_initial, s_zero, s_zerotoone, s_one, s_onetozero);
signal state : t_state := s_initial;

begin

process(clk) begin
	if(rising_edge(clk)) then
		case state is 
		
		when s_initial => 
			if (c_initval = '0') then
				state <= s_zero;
			else
				state <= s_one;
			end if;
		
		when s_zero =>
			signal_o <= '0';
			if(timer = c_timerlim - 1) then
				state <= s_zerotoone;
			end if;
			if(signal_i = '1') then
				state <= s_zerotoone;
			end if;
			
		when s_zerotoone =>
			signal_o <= '0';
			timer_en <= '1';
			if(signal_i = '0') then
				timer_en <= '0';
				state <= s_zero;
			end if;
			if(timer_tick = '1') then 
				timer_en <= '0';
				state <= s_one;
			end if;
			
		when s_one =>
			signal_o <= '1';
			if(signal_i = '0') then
				state <= s_onetozero;
			end if;
			
		when s_onetozero =>
			signal_o <= '1';
			timer_en <= '1';
			if(signal_i = '1') then
				timer_en <= '0';
				state <= s_one;
			end if;
			if(timer_tick = '1') then 
				timer_en <= '0';
				state <= s_zero;
			end if;
		end case;
	end if;
end process;

p_timer : process (clk) begin
	if(rising_edge(clk)) then
		if(timer_en = '1') then 
			timer_tick <= '0';
			timer <= timer + 1;
		else	
			timer <= 0;
			timer_tick <= '0';
		end if;
		if (timer = c_timerlim - 1) then 
				timer_tick <= '1';
				timer <= 0;
		end if;
	end if;
end process;
end Behavioral;
