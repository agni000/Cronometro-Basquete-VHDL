library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--!@entity Cronometro decrescente de basquete.
--!@brief Possui clock, reset e as entradas referentes ao setup do quarto (quarto, minutos, segundos e botoes),
--! 		 as saidas sao orientadas aos leds e aos displays correspondentes a seus identificadores.
entity cronometroDec is
	port(
		clock, reset : in std_logic;
		paraContinua, novoQuarto, carga : in std_logic;		--! Botoes.
		cQuarto 	: in std_logic_vector (1 downto 0);
		cMinutos : in std_logic_vector (3 downto 0);
		cSegundos : in std_logic_vector (5 downto 0);
		quarto : out std_logic_vector (1 downto 0); 			--! 4 leds.
		minutos : out std_logic_vector (3 downto 0); 		--! 4 leds.
		segundos : out std_logic_vector (5 downto 0); 		--! 2 displays.
		centesimos : out std_logic_vector (6 downto 0) 		--! 2 displays.
	);
end cronometroDec;

--!@architecture Cronometro decrescente de basquete.
--!@brief Logica da FMS e dos contadores de centesimos, segundos e minutos.
architecture cronometroDec of cronometroDec is
  
  --!Sinais para o divisor do clock
  --!50 MHz/100 = 500.000 ciclos
  constant CICLOS_NECESSARIOS : integer := 500000;
  signal contadorClock : integer range 0 to CICLOS_NECESSARIOS := 0;
  signal pulsoCentesimo : std_logic := '0';

  --!Sinais de controle
  signal contagemZerada : std_logic; 
  signal fimQuarto : std_logic; 
  
  --!Contadores internos
  signal contadorCentesimos : integer range 0 to 99; 
  signal contadorSegundos : integer range 0 to 59;
  signal contadorMinutos : integer range 0 to 15;
  signal contadorQuarto : integer range 1 to 4;

  --!Estados da maquina de estados
  type estadoFMS is (REP, CONTA, LOAD, PARADO);
  signal estado, proximoEstado : estadoFMS := REP;

--!Inicia implementacao da arquitetura
begin
	
  --!Processo gerador de centesimo
  geradorCentesimo: process(clock, reset)
  begin
		if reset = '1' then
			contadorClock <= 0;
			pulsoCentesimo <= '0';
		elsif rising_edge(clock) then
			if contadorClock = CICLOS_NECESSARIOS - 1 then
				contadorClock <= 0;
				pulsoCentesimo <= '1';
			else 
				contadorClock <= contadorClock + 1;
				pulsoCentesimo <= '0';
			end if;
		end if;
	end process; 

  --!Detecta fim de quarto
  contagemZerada <= '1' when (contadorMinutos = 0 and contadorSegundos = 0 and contadorCentesimos = 0) else '0';
  fimQuarto  <= contagemZerada;
  
  --!Bloco sincrono da FMS
  blocoSincronoFMS: process(clock, reset)
  begin 
		if reset = '1' then 
			estado <= REP; 
		elsif rising_edge(clock) then 
			estado <= proximoEstado;
		end if; 
  end process; 	
  
  --!Transicao de estados FMS
  maquinaDeEstados: process(estado, carga, paraContinua, fimQuarto, novoQuarto)
  begin
		proximoEstado <= estado; 
		case estado is
			when REP =>
				if paraContinua = '1' and contadorQuarto <= 4 then
					proximoEstado <= CONTA; 
				elsif carga = '1' then
					proximoEstado <= LOAD; 
				end if;
				
			when CONTA =>
				if paraContinua = '1' or fimQuarto = '1' then
					proximoEstado <= PARADO;
				end if; 
			
			when PARADO => 
				if novoQuarto = '1' and fimQuarto = '1' then 
					proximoEstado <= REP; 
				elsif paraContinua = '1' and fimQuarto = '0' then 
					proximoEstado <= CONTA; 
				elsif carga = '1' then 
					proximoEstado <= LOAD;
				end if; 
			
			when LOAD => 
				if paraContinua = '1' then 
					proximoEstado <= CONTA; 
				end if;
		end case;					
  end process; 

  --!Contadores de tempo
  contagem: process(clock, reset)
  begin 
		if reset = '1' then 
			contadorCentesimos <= 0;
			contadorSegundos <= 0;
			contadorMinutos <= 15; 
			contadorQuarto <= 1;
		elsif rising_edge(clock) then 
			case estado is 
				when CONTA => 
					if pulsoCentesimo = '1' then 
						if contadorCentesimos > 0 then 
							contadorCentesimos <= contadorCentesimos - 1;
						else 
							contadorCentesimos <= 99; 
							if contadorSegundos > 0 then 
								contadorSegundos <= contadorSegundos - 1;
							else 
								contadorSegundos <= 59; 
								if contadorMinutos > 0 then
									contadorMinutos <= contadorMinutos - 1; 
								else 
									contadorMinutos <= 0;
								end if; 
							end if;
						end if;
					end if;
				when LOAD => 
					contadorQuarto <= to_integer(unsigned(cQuarto)) + 1; --!Ajuste de 0-3 para 1-4
					contadorMinutos <= to_integer(unsigned(cMinutos));
					contadorCentesimos <= 0; 
					--!Caso particular dos segundos, que aceita somente inputs de 0, 15, 30 e 45 segundos.
					case to_integer(unsigned(cSegundos)) is
						when 0   => contadorSegundos <= 0;
						when 15  => contadorSegundos <= 15;
						when 30  => contadorSegundos <= 30;
						when 45  => contadorSegundos <= 45;
						when others => contadorSegundos <= 0;
					end case; 
				when PARADO =>
					if novoQuarto = '1' and fimQuarto = '1' then
						if contadorQuarto < 4 then
							contadorQuarto <= contadorQuarto + 1;
							contadorMinutos <= 15;
							contadorSegundos <= 0;
							contadorCentesimos <= 0;
						end if;
					end if;	
			end case;
		end if;
  end process; 

--!Atribuicoes das saidas
quarto <= std_logic_vector(to_unsigned(contadorQuarto - 1, 2)); --!Ajuste de 1-4 para 0-3
minutos <= std_logic_vector(to_unsigned(contadorMinutos, 4));
segundos <= std_logic_vector(to_unsigned(contadorSegundos, 6));
centesimos <= std_logic_vector(to_unsigned(contadorCentesimos, 7));  
end cronometroDec;

