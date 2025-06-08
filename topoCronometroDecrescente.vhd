library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--!@entity Entidade de topo para o cronometro de basquete
--!@brief Integra cronometro, debounce dos botoes e drivers dos displays
entity topoCronometroDec is
    port(
        --!Clock e Reset da placa
        clock50Mhz : in std_logic;           
        resetPlaca : in std_logic;           
        
        --!Botoes fisicos
        btnParaContinua : in std_logic;   
        btnNovoQuarto : in std_logic;   
        btnCarga : in std_logic;  
		  
		  --!Switches/chaves para configuração
        cQuarto   : in std_logic_vector(1 downto 0);   
        cMinutos  : in std_logic_vector(3 downto 0);   
        cSegundos : in std_logic_vector(1 downto 0);   
		  
		  --!LEDs para mostrar quarto e minutos
        ledsQuarto  : out std_logic_vector(3 downto 0);
        ledsMinutos : out std_logic_vector(3 downto 0);		
        
		  --!Display de 7 segmentos
        displaySeg : out std_logic_vector(7 downto 0); 
        displayAn  : out std_logic_vector(3 downto 0)	  
	 );
end topoCronometroDec;

--!@architecture Implementacao do arquivo de topo
architecture topoCronometroDec of topoCronometroDec is

  --!Sinais a serem convertidos pela ROM
  signal segundosBin : std_logic_vector(7 downto 0);
  signal centesimosBin : std_logic_vector(7 downto 0);
  
  --!Sinais de segundos e centesimos para o display 
  signal segundosBCD : std_logic_vector(7 downto 0);
  signal centesimosBCD : std_logic_vector(7 downto 0);
  
  --!Sinais auxiliares dos botoes pos-debounce
  signal btnDbParaContinua : std_logic;
  signal btnDbNovoQuarto : std_logic;
  signal btnDbCarga : std_logic;
  
  --!ROM de conversao para BCD
  type ROM is array (0 to 127) of std_logic_vector (7 downto 0);
  constant conv_to_BCD : ROM:=(
			"00000000", "00000001", "00000010", "00000011", "00000100", -- 01-09
			"00000101", "00000110", "00000111", "00001000", "00001001",
         "00010000", "00010001", "00010010", "00010011", "00010100", -- 10-19
			"00010101", "00010110", "00010111", "00011000", "00011001", 
			"00100000", "00100001", "00100010", "00100011", "00100100", -- 20-29
			"00100101", "00100110", "00100111", "00101000", "00101001",
			"00110000", "00110001", "00110010", "00110011", "00110100", -- 30-39
			"00110101", "00110110", "00110111", "00111000", "00111001",
			"01000000", "01000001", "01000010", "01000011", "01000100", -- 40-49

			"01000101", "01000110", "01000111", "01001000", "01001001",
			"01010000", "01010001", "01010010", "01010011", "01010100", -- 50-59
			"01010101", "01010110", "01010111", "01011000", "01011001",
			"01100000", "01100001", "01100010", "01100011", "01100100", -- 60-69
			"01100101", "01100110", "01100111", "01101000", "01101001",
			"01110000", "01110001", "01110010", "01110011", "01110100", -- 70-79  
			"01110101", "01110110", "01110111", "01111000", "01111001",
			"10000000", "10000001", "10000010", "10000011", "10000100", -- 80-89
			"10000101", "10000110", "10000111", "10001000", "10001001",
			"10010000", "10010001", "10010010", "10010011", "10010100", -- 90-99
			"10010101", "10010110", "10010111", "10011000", "10011001",
			"00000000", "00000000", "00000000", "00000000", "00000000", -- 100-109
			"00000000", "00000000", "00000000", "00000000", "00000000",
			"00000000", "00000000", "00000000", "00000000", "00000000", -- 110-119
			"00000000", "00000000", "00000000", "00000000", "00000000",		
			"00000000", "00000000", "00000000", "00000000", "00000000", -- 120-127
			"00000000", "00000000", "00000000"			
			);
			
  --!Vetor de dados para driver de display
  signal d0, d1, d2, d3 : std_logic_vector(5 downto 0);

begin
	
	--!Instancia do cronometro decrescente
	cronometroDecrescente : entity work.cronometroDec
	  port map (
		 clock => clock50Mhz,
		 reset => resetPlaca, 
		 paraContinua => btnDbParaContinua,
		 novoQuarto => btnDbNovoQuarto, 
		 carga => btnDbCarga, 
		 cQuarto => cQuarto,
		 cMinutos => cMinutos,
		 cSegundos => cSegundos,
		 quarto => ledsQuarto,
		 minutos => ledsMinutos,
		 segundos => segundosBin,
		 centesimos => centesimosBin
     );
  	
  --!Conversao para BCD usando ROM
  segundosBCD <= conv_to_BCD(segundosBin);
  centesimosBCD <= conv_to_BCD(centesimosBin);	
	
  d0 <= '1' & segundosBCD(7 downto 4) & '1';  
  d1 <= '1' & segundosBCD(3 downto 0) & '1';
  d2 <= '1' & centesimosBCD(7 downto 4) & '1';
  d3 <= '1' & centesimosBCD(3 downto 0) & '1';	
	
  --!Instancia do driver de display 
  displayDriver : entity work.dspl_drv
    port map (
      clock  => clock,
      reset  => reset,
      d0     => d0,
      d1     => d1,
      d2     => d2,
      d3     => d3,
      an 	 => displayAn,
      dec_ddp => displaySeg
    );

  --!Debounce botao novo-quarto	
  debounceNovoQuarto : entity work.Debounce
	 port map(
      clock  => clock50Mhz,
      reset  => resetPlaca,
		key    => btnNovoQuarto,
		debkey => btnDbNovoQuarto	
	 );
	
  --!Debounce botao para-continua	
  debounceParaContinua : entity work.Debounce
	 port map(
      clock  => clock50Mhz,
      reset  => resetPlaca,
		key    => btnParaContinua,
		debkey => btnDbParaContinua	
	 );
  
  --!Debounce botao carga	
  debounceNovoQuarto : entity work.Debounce
	 port map(
      clock  => clock50Mhz,
      reset  => resetPlaca,
		key    => btnCarga,
		debkey => btnDbCarga	
	 );
 	 
end topoCronometroDec;

