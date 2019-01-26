library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity projekt is
	port ( C : in std_logic;
			clocK_50MHz: in std_logic;
		RED2, RED1, RED0 : out std_logic;--, RED3, RED4, RED5, RED6, RED7: out std_logic;
	GRN2, GRN1, GRN0 : out std_logic;--, GRN3, GRN4, GRN5, GRN6, GRN7 : out std_logic;
	BLU1, BLU0 : out std_logic; --, BLU2 , BLU3, BLU4, BLU5, BLU6, BLU7 : out std_logic;
	H_SYNC, V_SYNC : inout std_logic		);
end projekt ;

architecture Bech of projekt is
-------------------------------------------------------------------------------
signal LFSR: std_logic_vector(4 downto 0);
SIGNAL rgb :STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL counter_clock :std_logic_vector( 4 downto 0 ) := "00000";
--SIGNAL counter_lfsr :std_logic_vector( 4 downto 0 ) := "00000";


-------------------------------------------------------------------------------


component vga is
port( CLOCK_50MHz	: in std_logic;  -- zegar 50 MHz
	RGB : in std_logic_vector(7 downto 0);
	RED2, RED1, RED0 : out std_logic;-- , RED3, RED4, RED5, RED6, RED7: out std_logic;
	GRN2, GRN1, GRN0 : out std_logic;--, GRN3, GRN4, GRN5, GRN6, GRN7 : out std_logic;
	BLU1, BLU0 : out std_logic;--, BLU2, BLU3, BLU4, BLU5, BLU6, BLU7 : out std_logic;
	H_SYNC, V_SYNC : inout std_logic  );
end component;

-------------------------------------------------------------------------------

begin

process( C )

begin


if rising_edge(C) then
	counter_clock <= counter_clock + 1; -- dodawanie licznika clockiem 
	LFSR(0)<= LFSR(1) xor LFSR(2)xor LFSR(3) xor LFSR(4);
	LFSR(4 downto 1) <= LFSR(3 downto 0);
--	counter_lfsr<=LFSR;
	
   if counter_clock="0001" then
	--if couter_clock=counter_lfsr then   -- warunek na równą wartosć liczników (na później)
	rgb<="11111111";
	else rgb<="00000000";
	end if;
	
end if;
end process;


c1: vga port map (clock_50MHz=>clocK_50MHz,
              				        RGB<=rgb,   --zmienione "=>" na "<=" ?
						RED0 <= red0,
						RED1<=RED1,
						--RED4=>RED4,
						--RED5=>RED5,
						--RED6=>RED6,
						--RED7=>RED7,
						red2 <= red2,
						grn0 <= grn0,
						grn1<=grn1,
						grn2<=grn2,
						--GRN3=>GRN3,
						--GRN4=>GRN4,
						--GRN5=>GRN5,
						--GRN6=>GRN6,
						--GRN7=>GRN7,
						blu0<=blu0,
						blu1<=blu1,
						--BLU2=>BLU2,
						--BLU3=>BLU3,
						--BLU4=>BLU4,
						--BLU5=>BLU5,
						--BLU6=>BLU6,
						--BLU7=>BLU7,
						h_sYNC<=h_sYNC,
						v_sYNC<=v_sYNC);


end Bech;
