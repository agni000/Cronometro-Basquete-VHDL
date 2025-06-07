LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

--!@entity Testbench para o cronometro decrescente de basquete
--!		  estamos utilizando o modelo padrao disponivel no ISE, 
--!		  com a adicao de alguns testes.
ENTITY tbCronometroDec IS
END tbCronometroDec;
 
ARCHITECTURE behavior OF tbCronometroDec IS 
 
    --!@component da UUT
    COMPONENT cronometroDec
    PORT(
         clock : IN  std_logic;
         reset : IN  std_logic;
         paraContinua : IN  std_logic;
         novoQuarto : IN  std_logic;
         carga : IN  std_logic;
         cQuarto : IN  std_logic_vector(1 downto 0);
         cMinutos : IN  std_logic_vector(3 downto 0);
         cSegundos : IN  std_logic_vector(5 downto 0);
         quarto : OUT  std_logic_vector(1 downto 0);
         minutos : OUT  std_logic_vector(3 downto 0);
         segundos : OUT  std_logic_vector(5 downto 0);
         centesimos : OUT  std_logic_vector(6 downto 0)
        );
    END COMPONENT;
    

   --!Inputs
   signal clock : std_logic := '0';
   signal reset : std_logic := '0';
   signal paraContinua : std_logic := '0';
   signal novoQuarto : std_logic := '0';
   signal carga : std_logic := '0';
   signal cQuarto : std_logic_vector(1 downto 0) := (others => '0');
   signal cMinutos : std_logic_vector(3 downto 0) := (others => '0');
   signal cSegundos : std_logic_vector(5 downto 0) := (others => '0');

 	--!Outputs
   signal quarto : std_logic_vector(1 downto 0);
   signal minutos : std_logic_vector(3 downto 0);
   signal segundos : std_logic_vector(5 downto 0);
   signal centesimos : std_logic_vector(6 downto 0);

   --!Definicao do clock
   constant clock_period : time := 10 ps;
 
BEGIN
 
	--!Instancia a UUT
   uut: cronometroDec PORT MAP (
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
   clockProc :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   --!Estimulos 
   estimulosProc: process
   begin		
        --!Teste 1: Reset inicial
        report "=== TESTE 1: Reset inicial ===";
        reset <= '1';
        wait for 10 ps;
        reset <= '0';
        wait for 10 ps;
		  
		  --!Verificar estado inicial
        assert quarto = "00" report "Erro: Quarto inicial deveria ser 0" severity error;
        assert minutos = "1111" report "Erro: Minutos iniciais deveriam ser 15" severity error;
        assert segundos = "000000" report "Erro: Segundos iniciais deveriam ser 0" severity error;
        assert centesimos = "0000000" report "Erro: Centesimos iniciais deveriam ser 0" severity error;
        report "Reset inicial - OK";
        
		  --!Teste 2: Carregamento de valores
        report "=== TESTE 2: Carregamento de valores ===";
        cQuarto <= "01";    -- Quarto 2 (representado como 1)
        cMinutos <= "1010"; -- 10 minutos
        cSegundos <= "001111"; -- 15 segundos
        carga <= '1';
        wait for 10 ps;
        carga <= '0';
        wait for 10 ps;

        --!Verificar carregamento
        assert quarto = "01" report "Erro: Quarto nao carregado corretamente" severity error;
        assert minutos = "1010" report "Erro: Minutos nao carregados corretamente" severity error;
        assert segundos = "001111" report "Erro: Segundos nao carregados corretamente" severity error;
        report "Carregamento - OK";
		  
        --!Teste 3: Iniciar contagem
        report "=== TESTE 3: Iniciar contagem ===";
        paraContinua <= '1';
        wait for 10 ps;
        paraContinua <= '0';

        --!Aguardar alguns ciclos de contagem (simular alguns centesimos)
        wait for 5 ms; -- Tempo suficiente para alguns decrementos

        --!Verificar se está contando
        report "Tempo apos contagem: " & 
               "Q=" & integer'image(to_integer(unsigned(quarto))) &
               " M=" & integer'image(to_integer(unsigned(minutos))) &
               " S=" & integer'image(to_integer(unsigned(segundos))) &
               " C=" & integer'image(to_integer(unsigned(centesimos)));		  
      wait;
   end process;

END;
