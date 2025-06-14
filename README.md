# Cronômetro de Basquete em VHDL 

Um cronômetro decrescente para jogos de basquete implementado em VHDL, projetado para FPGAs com display de 7 segmentos e switches. Este é o terceiro trabalho da matéria Linguagem de Descrição de Hardware. 

## Descrição

Este projeto implementa um cronômetro completo para partidas de basquete, com as seguintes funcionalidades:

- **Cronômetro decrescente** com precisão de centésimos de segundo
- **Controle de quartos** (1º, 2º, 3º, 4º quarto)
- **Display de 7 segmentos** para visualização do tempo
- **LEDs indicadores** para quarto atual e minutos
- **Debounce de botões** para eliminar ruídos e sinais prolongados 
- **Configuração flexível** através de switches/chaves

## Funcionalidades

### Controles Principais
- **Para/Continua**: Pausa e retoma a contagem do cronômetro
- **Novo Quarto**: Avança para o próximo quarto e reinicia o tempo
- **Carga**: Carrega uma nova configuração de tempo

### Configuração
- **Quarto**: Seleção do quarto atual (2 bits)
- **Minutos**: Configuração dos minutos iniciais (4 bits)
- **Segundos**: Configuração dos segundos iniciais, com setup de 0, 15, 30 e 45 segundos (2 bits)

### Visualização
- **Display 7 segmentos**: Mostra segundos e centésimos (formato SS.CC)
- **LEDs de Quarto**: Indicação visual do quarto atual (one-hot encoding)
- **LEDs de Minutos**: Indicação dos minutos restantes

## Arquitetura do Sistema

```
topoCronometroDec (Entidade Principal)
├── cronometroDec (Módulo do Cronômetro)
├── dspl_drv (Driver do Display)
├── Debounce (x3) (Debounce dos Botões)
└── ROM de Conversão BCD
```

### Componentes Principais

1. **Cronômetro Decrescente** (`cronometroDec`)
   - Lógica principal de contagem regressiva
   - Controle de estados (parado/rodando)
   - Gerenciamento de quartos

2. **Driver de Display** (`dspl_drv`)
   - Multiplexação dos displays de 7 segmentos
   - Conversão para códigos de display

3. **Sistema de Debounce**
   - Elimina ruídos dos botões físicos
   - Garante operação confiável

4. **Conversão BCD**
   - ROM para conversão decimal → BCD
   - Suporte para valores de 0 a 99

## Pinagem

### Entradas para o topo da hierarquia;
| Sinal | Tipo | Descrição |
|-------|------|-----------|
| `clock50Mhz` | `std_logic` | Clock principal da placa |
| `resetPlaca` | `std_logic` | Reset global do sistema |
| `btnParaContinua` | `std_logic` | Botão para pausar/continuar |
| `btnNovoQuarto` | `std_logic` | Botão para novo quarto |
| `btnCarga` | `std_logic` | Botão para carregar configuração |
| `cQuarto` | `std_logic_vector(1:0)` | Chaves de setup para o quarto |
| `cMinutos` | `std_logic_vector(3:0)` | Chaves de setup para os minutos |
| `cSegundos` | `std_logic_vector(1:0)` | Chaves de setup para os segundos |

### Saídas do topo da hierarquia; 
| Sinal | Tipo | Descrição |
|-------|------|-----------|
| `ledsQuarto` | `std_logic_vector(3:0)` | LEDs indicadores do quarto |
| `ledsMinutos` | `std_logic_vector(3:0)` | LEDs indicadores dos minutos |
| `displaySeg` | `std_logic_vector(7:0)` | Segmentos do display |
| `displayAn` | `std_logic_vector(3:0)` | Anodos do display |
