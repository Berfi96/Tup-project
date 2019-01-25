--   vga.vhd 
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
 
entity vga is
port( CLOCK_50MHz	: in std_logic;  -- zegar 50 MHz
	RGB : in std_logic_vector(7 downto 0);
	RED2, RED1, RED0 , RED3, RED4, RED5, RED6, RED7: out std_logic;
	GRN2, GRN1, GRN0, GRN3, GRN4, GRN5, GRN6, GRN7 : out std_logic;
	BLU1, BLU0, BLU2, BLU3, BLU4, BLU5, BLU6, BLU7 : out std_logic;
	H_SYNC, V_SYNC: inout std_logic  );
end;
 
architecture beh of vga is
	signal clock_25MHz  : std_logic;  -- zegar 25 MHz
	signal video_on     : std_logic;
	signal h_count      : std_logic_vector(9 downto 0);  -- licznik kolumn
	signal v_count      : std_logic_vector(9 downto 0);  -- licznik wierszy
	signal pixel_column : std_logic_vector(9 downto 0);  -- sygnal pomocniczy
	signal pixel_row    : std_logic_vector(9 downto 0);  -- sygnal pomocniczy
 
begin
 
	process(CLOCK_50MHz)  -- dzielnik 50mhz przez 2 =25mhz
		variable q_int : std_logic_vector(1 downto 0);
	begin
		if rising_edge(CLOCK_50MHz) then q_int:=q_int+2; end if;
		clock_25MHz<=q_int(1);
	end process;
 
	process(clock_25MHz)  -- licznik kolumn
	begin
		if rising_edge(clock_25MHz) then
 		if h_count<793 then h_count<=h_count+1; else h_count<=(others=>'0'); end if;
 		end if;
 	end process;
 
 	process(H_SYNC)  -- licznik wierszy
 	begin
 		if rising_edge(H_SYNC) then
 			if v_count<524 then v_count<=v_count+1; else v_count<=(others=>'0'); end if;
 		end if;
 	end process;
 
 	process(clock_25MHz)  -- impulsy synchronizacji
 	begin
 		if rising_edge(clock_25MHz) then
 			if (h_count>=660) and (h_count<=750) then H_SYNC<='0'; else H_SYNC<='1'; end if;
 			if (v_count>=491) and (v_count<=492) then V_SYNC<='0'; else V_SYNC<='1'; end if;
 		end if;
 	end process;
 
 	pixel_column<=h_count; pixel_row<=v_count;
 	video_on<='1' when (h_count<640 and v_count<480) else '1';  -- wygaszanie  --tu zmienilem else na 1
 
 	process(clock_25MHz)  -- generowanie sygnalow REDn, GRNn i BLUn
 	begin
 		if rising_edge(clock_25MHz) then
 			RED0 <= RGB(7) and video_on;
 			RED1 <= RGB(6) and video_on;
 			RED2 <= RGB(5) and video_on;
			
			RED3 <= RGB(4) and video_on;
 			RED4 <= RGB(3) and video_on;
 			RED5 <= RGB(2) and video_on;
			RED6 <= RGB(1) and video_on;
 			RED7 <= RGB(0) and video_on;
			
 			BLU0 <= RGB(7) and video_on;
 			BLU1 <= RGB(6) and video_on;
 			BLU2 <= RGB(5) and video_on;
			
			BLU3 <= RGB(4) and video_on;
 			BLU4 <= RGB(3) and video_on;
 			BLU5 <= RGB(2) and video_on;
			BLU6 <= RGB(1) and video_on;
 			BLU7 <= RGB(0) and video_on;
			
			GRN0 <= RGB(7) and video_on;
 			GRN1 <= RGB(6) and video_on;
 			GRN2 <= RGB(5) and video_on;
			
			GRN3 <= RGB(4) and video_on;
 			GRN4 <= RGB(3) and video_on;
 			GRN5 <= RGB(2) and video_on;
			GRN6 <= RGB(1) and video_on;
 			GRN7 <= RGB(0) and video_on;
 		end if;
 	end process;
 
end beh;
