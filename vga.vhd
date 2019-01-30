library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
 
entity vga is
    port
    (
        clk_50 : in std_logic;                      --Zegar 50MHz
        RED2, RED1, RED0 , RED3, RED4, RED5, RED6, RED7: out std_logic;
	GRN2, GRN1, GRN0, GRN3, GRN4, GRN5, GRN6, GRN7 : out std_logic;
	BLU1, BLU0, BLU2, BLU3, BLU4, BLU5, BLU6, BLU7 : out std_logic;
	key: std_logic_vector (3 downto 0);
        vga_hs : out std_logic;                     --impuls synchronizacji poziomej
        vga_vs : out std_logic;  		    --impuls synchronizacji pionowej
	vga_clk: out std_logic;			    --Zegar doprowadzany do przetwornika VGA 25MHz
	n_sync : out std_logic;                    
        n_blank : out std_logic;		 
        pix_x : out std_logic_vector(9 downto 0);   --wspolrzedne aktualnie wyswietlanego piksela (x)
        pix_y : out std_logic_vector(8 downto 0);    --wspolrzedne aktualnie wyswietlanego piksela (y)
	diody: out std_logic_vector(15 downto 0)
    );
end vga;

architecture Bech of vga is
	
signal clk_25 : std_logic; --Zegar działający w 25MHz
signal xcounter : integer range 0 to 799;  
signal ycounter : integer range 0 to 524; 
signal count: integer:=1;
signal tmp : std_logic := '0';
signal rgb :std_logic_vector(23 downto 0) :=(others=>'0');
signal rgb2 :std_logic_vector(23 downto 0) :=(others=>'0');
SIGNAL counter_clock :integer;
signal licznik: integer :=3;

----------------------------------------------------------
begin
   process (clk_50)    --generowanie sygnału 25MHz wykorzystując dzielnik częstotliwości
   begin
        if rising_edge(clk_50) then
            clk_25 <= not clk_25;
        end if;
    end process;
----------------------------------------------------------- 
    
process(clk_25)
 variable LFSR: std_logic_vector(29 downto 0) :="000001110001001000000000001010"; --Rejestr przesuwający z liniowym sprzężeniem zwrotnym wykorzystywany do wygenerowania losowej liczby która porównywana będzie z licznikiem nabijanym za pomocą zegara 
 variable counter_lfsr :std_logic_vector(29 downto 0 ) := (others=>'0');
 variable LFSR_rgb: std_logic_vector(23 downto 0) :="000001110001001000000000";--Rejestr przesuwający z liniowym sprzężeniem zwrotnym wykorzystywany do wygenerowania losowej wartości koloru górnej połówki ekranu
 variable counter_lfsr_rgb :std_logic_vector(23 downto 0 ) := (others=>'0');
 variable LFSR_rgb2: std_logic_vector(23 downto 0):="001100111000100100001100";--Rejestr przesuwający z liniowym sprzężeniem zwrotnym wykorzystywany do wygenerowania losowej wartości koloru dolnej połówki ekranu
 variable counter_lfsr_rgb2 :std_logic_vector(23 downto 0 ) := (others=>'0');
 variable ileCzasu : integer; -- zmienna przechowująca wartość czasu w milisekundach od naciśnięcia przycisku 
 
 begin
	 
------------------------------- maszyna stanów
 if rising_edge(clk_25) then
	
	if licznik=0 then   -- pierwszy stan maszyny, pseudolosowe generowanie liczb
		------- proces generowania losowych wartości 
		LFSR(0):=LFSR(1) xor LFSR(3) xor LFSR (5) xor LFSR(10) xor LFSR(15) xor LFSR (20); 
		LFSR:= LFSR(0)&LFSR(29 downto 1);
		counter_lfsr:=LFSR;
		LFSR_rgb(0):=LFSR_rgb(1) xor LFSR_rgb(3) xor LFSR_rgb (5) xor LFSR_rgb(10) xor LFSR_rgb(15) xor LFSR_rgb (20);
		LFSR_rgb:= LFSR_rgb(0)&LFSR_rgb(23 downto 1);
		rgb<=LFSR_rgb;
		LFSR_rgb2(0):=LFSR_rgb2(1) xor LFSR_rgb2(3) xor LFSR_rgb2 (5) xor LFSR_rgb2(10) xor LFSR_rgb2(15) xor LFSR_rgb2 (20);
		LFSR_rgb2:= LFSR_rgb2(0)&LFSR_rgb2(23 downto 1);
		licznik<=1; --zwiększenie licznika w celu zmiany stanu maszyny na następny
		-----------------------------
		elsif licznik =1 then -- drugi stan maszyny, porównanie wartości licznika nabijanego zegarem z wartością wygenerowaną w pierwszym stanie maszyny
			if counter_clock=counter_lfsr then	
		   		rgb2<=LFSR_rgb2;	
				rgb<=LFSR_rgb;
				licznik<=2; --zwiększenie licznika w celu zmiany stanu maszyny na następny
			else
				counter_clock <= counter_clock + 1; -- inkrementacja licznika
				diody<=(others=>'0'); 
				rgb<=(others=>'0');
				end if;
			
			elsif licznik=2 then   
			   if key(3)='1' then 
			  	 ileCzasu:=ileCzasu+1;
				 rgb <= rgb;
			   else
				   licznik<=3; --zwiększenie licznika w celu zmiany stanu maszyny na następny
				   diody <= std_logic_vector(to_unsigned(ileczasu/25000,16));
				   rgb<=rgb;
			   end if;
	      elsif licznik=3 then 
		      
			   if key(2)='0' then
				  licznik<=0;
				  rgb<=(others=>'0');
				  ileczasu:=0;
				  counter_clock<=0;
				  diody<=(others=>'0');
				  rgb2<=(others=>'0');
			   else
				  rgb <= rgb;
			   end if;
		end if;	
	end if;	 
 end process;
	 
--------------------------------------------------------- 
    process (clk_25)
    begin
        if rising_edge(clk_25) then
            if xcounter = 799 then
                xcounter <= 0;
               if ycounter = 524 then  
                    ycounter <= 0;
                else
                    ycounter <= ycounter + 1;
                end if;
            else
                xcounter <= xcounter + 1;
            end if;
        end if;
		  end process;   
    
process (clk_25) 
	begin
	 if rising_edge(clk_25) then
	 
	 if xcounter >= 16 and  xcounter < 112 then
	    vga_hs <= '0';
	 else
	    vga_hs<='1';
	 end if;
	 
	 if ycounter >= 10 and ycounter < 12 then
	    vga_vs <= '0';
	 else
	    vga_vs <= '1';
	 end if; 
	 end if;
	 end process;
	 
	 
n_blank<='1';
n_sync<='0';
vga_clk<=clk_25;

 
process (xcounter, ycounter,rgb,clk_25)
    begin
if rising_edge(clk_25) then
        if xcounter < 160 or ycounter < 45 then
          	        RED0 <='0';
 			RED1 <= '0';
 			RED2 <= '0';
			RED3 <= '0';
 			RED4 <='0';
 			RED5 <= '0';
			RED6 <= '0';
 			RED7 <= '0';
			BLU0 <= '0';
 			BLU1 <= '0';
 			BLU2 <='0';
			BLU3 <= '0';
 			BLU4 <= '0';
 			BLU5 <= '0';
			BLU6 <='0';
 			BLU7 <= '0';
			GRN0 <='0';
 			GRN1 <= '0';
 			GRN2 <= '0';
			GRN3 <= '0';
 			GRN4 <= '0';
 			GRN5 <= '0';
			GRN6 <= '0';
 			GRN7 <= '0';
			  
       else
		 
		    if ycounter <300 then
       		        RED0 <= RGB(23) ;
	       		RED1 <= RGB(22)   ;
 			RED2 <= RGB(21)   ;
			RED3 <= RGB(20)  ;
 			RED4 <= RGB(19)  ;
 			RED5 <= RGB(18)   ;
			RED6 <= RGB(17)  ;
 			RED7 <= RGB(16)  ;
 			BLU0 <= RGB(15)  ;
 			BLU1 <= RGB(14)  ;
 			BLU2 <= RGB(13)  ;
			BLU3 <= RGB(12)   ;
 			BLU4 <= RGB(11)  ;
 			BLU5 <= RGB(10)   ;
			BLU6 <= RGB(9)  ;
 			BLU7 <= RGB(8)  ;
			GRN0 <= RGB(7)   ;
 			GRN1 <= RGB(6)  ;
 			GRN2 <= RGB(5)   ;
			GRN3 <= RGB(4)  ;
 			GRN4 <= RGB(3)   ;
 			GRN5 <= RGB(2)   ;
			GRN6 <= RGB(1)   ;
 			GRN7 <= RGB(0)   ;
			else
         		RED0 <= RGB2(23) ; 
 			RED1 <= RGB2(22) ;
 			RED2 <= RGB2(21) ;
			RED3 <= RGB2(20) ;
 			RED4 <= RGB2(19)  ;
 			RED5 <= RGB2(18)  ;			
			RED6 <= RGB2(17)  ;
 			RED7 <= RGB2(16)  ;
 			BLU0 <= RGB2(15) ;
 			BLU1 <= RGB2(14)  ;
 			BLU2 <= RGB2(13)  ;			
			BLU3 <= RGB2(12) ;
 			BLU4 <= RGB2(11)  ;
 			BLU5 <= RGB2(10)  ;
			BLU6 <= RGB2(9) ; 			
			BLU7 <= RGB2(8) ;
			GRN0 <= RGB2(7) ;
 			GRN1 <= RGB2(6)  ;
 			GRN2 <= RGB2(5) ;
			GRN3 <= RGB2(4)  ;
 			GRN4 <= RGB2(3);
 			GRN5 <= RGB2(2) ;
			GRN6 <= RGB2(1)  ;
 			GRN7 <= RGB2(0) ;			
			end if;
			
        end if;
 end if;
end process;

	 process (xcounter)
    begin
        if xcounter >= 160 then
            pix_x <= std_logic_vector(to_unsigned(xcounter - 160, pix_x'length));
        else
        pix_x <= std_logic_vector(to_unsigned(640, pix_x'length));
        end if;
    end process;
    
    process (ycounter)
    begin
        if ycounter >= 41 then
            pix_y <= std_logic_vector(to_unsigned(ycounter - 41, pix_y'length));
        else
            pix_y <= std_logic_vector(to_unsigned(480, pix_y'length));
        end if;
    end process;
	 
end Bech;
