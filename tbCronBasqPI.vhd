library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--!@entity Testbench para o cronometro de basquete
entity tbCronBasq is
end tbCronBasq;

--!@architecture Implementa o testbench 
architecture tbCronBasq of tbCronBasq is 
  
   --!Inputs
   signal clock : std_logic := '0';
   signal reset : std_logic := '0';
   signal paraContinua : std_logic := '0';
   signal novoQuarto : std_logic := '0';
   signal carga : std_logic := '0';
   signal cQuarto : std_logic_vector(1 downto 0) := (others => '0');
   signal cMinutos : std_logic_vector(3 downto 0) := (others => '0');
   signal cSegundos : std_logic_vector(1 downto 0) := (others => '0');

   --!Outputs
   signal quarto : std_logic_vector(1 downto 0);
   signal minutos : std_logic_vector(3 downto 0);
   signal segundos : std_logic_vector(5 downto 0);
   signal centesimos : std_logic_vector(6 downto 0);
	
   signal clockPeriodo : time := 10 ns;
 
begin
 
   --!Instancia a UUT
   uut: entity work.cronBasqPI
	generic map (
			 --!Vai deixar a simulacao mais rapida
			 MAXCOUNT => 50  
   	)
	port map(
          clock => clock,
          reset => reset,
          paraContinua => paraContinua,
          novoQuarto => novoQuarto,
          carga => carga,
          cQuarto => cQuarto,
          cMinutos => cMinutos,
          cSegundos => cSegundos,
          quarto => quarto,
          minutos => minutos,
          segundos => segundos,
          centesimos => centesimos
   	);

   --!Gerador de clock
   clockProc: process
   begin
		clock <= '0';
		wait for clockPeriodo/2;
		clock <= '1';
		wait for clockPeriodo/2;
   end process;
 
   --!Estimulos 
   estimulosProc: process
   begin		
        --!Teste 1: Reset inicial
        report "=== TESTE 1: Reset inicial ===";
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        wait for 100 ns;
		  
		  --!Verificar estado inicial
        assert quarto = "00" report "Erro: Quarto inicial deveria ser 0" severity error;
        assert minutos = "1111" report "Erro: Minutos iniciais deveriam ser 15" severity error;
        assert segundos = "000000" report "Erro: Segundos iniciais deveriam ser 0" severity error;
        assert centesimos = "0000000" report "Erro: Centesimos iniciais deveriam ser 0" severity error;
        report "Reset inicial - OK";
        
	--!Teste 2: Carregamento de valores
        report "=== TESTE 2: Carregamento de valores ===";
        cQuarto <= "01";    --!Quarto 2 (representado como 1)
        cMinutos <= "0001"; --!minutos
        cSegundos <= "00"; --!segundos
        carga <= '1';
        wait for 50 ns;
        carga <= '0';
        wait for 100 ns;

        --!Verificar carregamento
        assert quarto = "01" report "Erro: Quarto nao carregado corretamente" severity error;
        assert minutos = "0001" report "Erro: Minutos nao carregados corretamente" severity error;
        assert segundos = "000000" report "Erro: Segundos nao carregados corretamente" severity error;
        report "Carregamento - OK";
		  
        --!Teste 3: Iniciar contagem
        report "=== TESTE 3: Iniciar contagem ===";
        paraContinua <= '1';
        wait for 50 ns;
        paraContinua <= '0';

        --!Aguardar alguns ciclos de contagem (simular alguns centesimos)
        wait for 5 ms; --!Tempo suficiente para alguns decrementos

	--!Teste 4: Novo quarto apos contagem
	report "=== TESTE 4: Iniciar novo quarto ===";
	novoQuarto <= '1';
	wait for 50ns;
	novoQuarto <= '0'; 	
	wait for 100ns;
			
	--!Verificar se o quarto avancou e o restante das variaveis foi inicializado corretamente
        assert quarto = "10" report "Erro: Quarto nao carregado corretamente" severity error;
	assert minutos = "1111" report "Erro: Minutos iniciais deveriam ser 15" severity error;
        assert segundos = "000000" report "Erro: Segundos iniciais deveriam ser 0" severity error;
        assert centesimos = "0000000" report "Erro: Centesimos iniciais deveriam ser 0" severity error;
	report "Novo quarto - OK";
      wait;
   end process;

end;