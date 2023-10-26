# Controle de CNC

O objetivo do trabalho é implementar o controle de uma CNC de dois eixos (X e Y) em VHDL. CNCs (Computer Numeric Control) são sistemas que permitem o controle simultâneo de vários eixos de uma máquina, através de uma lista de movimentos escrita num código específico (código G). Neste trabalho, essa CNC será responsável pelo corte de peças a laser no formato de um triângulo.
Para simplificar, não trabalharemos com G-codes, e sim quatro pontos: os três vértices do triângulo e o ponto de início/fim da mesa de corte.

![](https://github.com/MiguelGrigorio/controle-de-cnc/blob/6c13a268f58f962280d1747e23dbaf48f8afea8c/Screenshot%202023-10-26%20at%2018.44.20.png)

## Funcionamento do Sistema

Neste trabalho, você deverá projetar em VHDL **o circuito que controlará o atuador laser e os motores X e Y (responsáveis pelo atuador laser e pela mesa, respectivamente).**

![](https://github.com/MiguelGrigorio/controle-de-cnc/blob/b78876c34ecd2c8949c2ffbe0a72157b739105f5/Screenshot%202023-10-26%20at%2018.56.01.png)
**Motor X (laser)**

![](https://github.com/MiguelGrigorio/controle-de-cnc/blob/b78876c34ecd2c8949c2ffbe0a72157b739105f5/Screenshot%202023-10-26%20at%2018.56.17.png)
**Motor Y (mesa)**

O sistema deverá seguir a lógica a seguir:
- Esperar os quatro pontos a serem enviados pelo Arduino
- Depois de receber os pontos, o sistema deverá esperar o usuário apertar um de três botões:


  **Botão A**: se pressionado, os motores devem se mover de forma a ir inicialmente para o ponto (X0,Y0), esperar 2 segundos e depois seguir para os pontos (X1,Y1), (X2,Y2), (X3,Y3), (X1,Y1) e (X0,Y0) nesta sequência, movimentando ambos motores ao mesmo tempo. Essa sequência serve para que a CNC realize o corte da peça no formato desejado e depois retorne ao ponto inicial (X0,Y0). A imagem abaixo apresenta esse movimento
  ![](https://github.com/MiguelGrigorio/controle-de-cnc/blob/eca439d064bc18f095ec1e28a53d9477eaef9a7b/Screenshot%202023-10-26%20at%2019.04.59.png)
  Perceba que apenas no momento que o atuador está se movendo de 1 para 2, de 2 para 3 e de 3 para 1 que o laser deve estar ligado. Depois de executada esta tarefa, o sistema volta para o estado do item 2: espera de comando

  **Botão B**: se pressionado, os motores devem se mover de forma a fazer um retângulo em volta da área a ser cortada. Esse comando serve para que o usuário saiba se o corte escapará do material a ser cortado sobre a mesa. A imagem abaixo apresenta esse movimento
  ![](https://github.com/MiguelGrigorio/controle-de-cnc/blob/eca439d064bc18f095ec1e28a53d9477eaef9a7b/Screenshot%202023-10-26%20at%2019.05.13.png)
  O atuador deve se mover desligado na sequência de pontos do quadrado: 1 -> 2 -> 3 -> 4 -> 1, e depois parar. Depois de executada esta tarefa, o sistema volta para o estado do item 2: espera de comando
  
  **Botão C**: se pressionado, o sistema voltará para o estado do item 1: espera dos quatro pontos, como se tivesse reiniciado o sistema

## Observações sobre o Sistema
- Enquanto o sistema estiver executando alguma tarefa, qualquer botão pressionado deverá ser ignorado
- No momento permitido, caso mais de um botão seja pressionado, o comando a ser executado deve respeitar a ordem de prioridade: Botão A >> Botão B >> Botão C
- Considere que o usuário enviará apenas pontos que gerem triângulos nos formatos dados abaixo, em que a = b
![](https://github.com/MiguelGrigorio/controle-de-cnc/blob/42d6ecba6530b410e6c79258f8c735fb19c2978b/Screenshot%202023-10-26%20at%2019.31.13.png)

## Envio dos Pontos
Quando o usuário for **enviar os quatro pontos, (X0,Y0), (X1,Y1), (X2,Y2) e (X3,Y3), pelo arduino** para a FPGA, esses pontos chegarão na FPGA por meio do módulo uart_module. Esse componente disponibilizará os valores de X0, Y0, X1, Y1, X2, Y2, X3 e Y3 em:

**data0**: “000”&’0’&X0

**data1**: “001”&’0’&Y0

**data2**: “010”&’0’&X1

**data3**: “011”&’0’&Y1

**data4**: “100”&’0’&X2

**data5**: “101”&’0’&Y2

**data6**: “110”&’0’&X3

**data7**: “111”&’0’&Y3

Além disso, esse módulo avisará que os dados estão disponíveis colocando o sinal validData em ‘1’.

**OBS**: Caso o validData se torne ‘1’ (informando que pontos foram recebidos) fora da etapa do item 1 da seção de funcionamento do sistema, esses pontos devem ser ignorados!

## Comunicação Serial - UART: Envio dos Pontos
Os pontos serão enviados por comunicação UART. Essa comunicação funciona da seguinte maneira (https://paginas.fe.up.pt/~hsm/docencia/comp/uart/):

![](https://github.com/MiguelGrigorio/controle-de-cnc/blob/dca7ae568b0b617fabe5868c287fa1987f77a3ef/Screenshot%202023-10-26%20at%2020.36.52.png)

- A linha de comunicação rx fica em ‘1’ (idle, do inglês, ocioso) até que se deseja enviar uma informação;
- Para se enviar um dado de 8 bits, a linha deve ser colocada em ‘0’ (start bit) por um período de 1 bit;
- Em seguida, são enviados os 8 bits de dados, sendo que cada bit possui o tempo de 1 bit;
- Para finalizar, coloca-se a linha em ‘1’ pelo período de 1 bit (stop bit), e mantêm-se dessa maneira (‘1’) até que deseje-se enviar outro dado de 8 bits.

Para a comunicação em 9600 bps, o bit terá um período T de 1/9600 segundos (104,17μs).

## Códigos Base e Ligação da CNC com a FPGA 

- Para realizar a comunicação serial, será necessário utilizar os módulos uart_module e uart_core, presentes na pasta do trabalho. Um arquivo básico de utilização destes módulos (cnc.vhd) também se encontra na pasta do trabalho.
- O código em arduino já está feito e gravado. Não é necessário implementá-lo. Entretanto, caso queira ver o código, ele está presente na pasta do trabalho.
- Os códigos dos pinos para acessar o laser, as bobinas de cada motor de passo (X e Y) e o fio de comunicação com o arduino (R) se encontram no pinmap.txt do trabalho.

A imagem abaixo apresenta o que seria cada pino:

![](https://github.com/MiguelGrigorio/controle-de-cnc/blob/36549f5976b9566e3e87daa3503f9f7b0c67e64a/Screenshot%202023-10-26%20at%2020.40.07.png)

## Resumo das Entradas e Saídas

- Para realizar esse projeto, o sistema deverá apresentar minimamente as seguintes entradas e saídas:
- 4 botões: Reset, Botão A, Botão B e Botão C;
- O clock;
- 4 wires para controlar o motor de passo do Motor X;
- 4 wires para controlar o motor de passo do Motor Y;
- 1 wire para o rx (R) da comunicação serial;
- 1 LED para representar o laser.

A forma de conectar os fios da CNC pode ser vista na imagem abaixo. Observe que os quadrados roxo e azul recebem os fios roxo e azul, respectivamente. Além disso, nos cabos do wiresY, há um soquete de 6 pinos com apenas 5 fios; o sexto slot está vazio e seu local na FPGA está destacado na imagem.
Para que o pino rx (GPIO 25) funcione como I/O, é necessário mudar uma chave atrás da placa para OFF (HEX2 D3). Esse pino é comum com um dos LEDs do display de 7 segmentos HEX2. Essa chave seleciona se o pino será usado para o display ou para I/O.
![](https://github.com/MiguelGrigorio/controle-de-cnc/blob/ff126bc5896cbe3815eddb43fe8426519db363be/Screenshot%202023-10-26%20at%2020.42.28.png)

![](https://github.com/MiguelGrigorio/controle-de-cnc/blob/ff126bc5896cbe3815eddb43fe8426519db363be/Screenshot%202023-10-26%20at%2020.42.53.png)
