
Corte-e-costura 1.0
-------------------

1. Introdu��o
2. Estrutura do pacote
3. Mantas de retalhos
4. Listas de exemplos de palavras de cor e de roupa
5. Regras de anota��o
6. Programas
7. Agradecimentos


1. Introdu��o
-------------------------------

Este pacote est� acess�vel a partir de
http://www.linguateca.pt/acesso/corte-e-costura/corte-e-costura-1.0.zip,
e inclui:

- os programas necess�rios para anotar os corpos do AC/DC, no formato
  do PALAVRAS, com anota��o sem�ntica;

- dois corpos de teste: manta-de-retalhos_formatoregras, com v�rios
  exemplos que permitem ilustrar a sintaxe das regras que podem ser
  aplicadas pelo programa corte-e-costura, e
  manta-de-retalhos_fluxoregras, com v�rios exemplos que permitem
  ilustrar os v�rios tipos de regras e o fluxo de programas que os
  aplicam.

- listas de exemplos de palavras pertencentes aos campos sem�nticos da
  cor e da roupa;

- conjuntos de regras de anota��o.

Documenta��o adicional pode ser acedida usando o SUPeRB
(http://www.linguateca.pt/superb/busca_publ.pl?q=tags%253AACDC;script_link=1)
ou consultando a p�gina dedicada ao corte-e-costura
(http://www.linguateca.pt/ACDC/corte-e-costura/).


2. Estrutura do pacote
-------------------------------

Este pacote cont�m quatro directorias, que compreendem os recursos
indicados em 3., 4., 5., e 6., respectivamente:

corpos/
lexicos/
regras/
programas/


3. Mantas de retalhos
--------------------

O pacote inclui duas mantas de retalhos:

- manta-de-retalhos_formatoregras, que permite testar o programa
  corte-e-costura, ilustrando a sintaxe das regras que o programa
  consegue reconhecer e aplicar. O corpo foi criado a partir de frases
  existentes nos corpos do AC/DC, que foram nalguns casos replicadas e
  modificadas para prever todos os casos de regras que se
  ilustram. Deve usar-se em combina��o com o programa de teste
  acdc_corte-e-costura_teste.sh (ver sec��o 6. Programas).

- manta-de-retalhos_fluxoregras, que permite testar o pacote
  corte-e-costura, ilustrando os diferentes tipos de regras (de
  correc��o, positivas, negativas, de especializa��o e recursivas) e o
  fluxo completo de aplica��o dos v�rios programas com listas de
  exemplos e regras. O corpo foi criado apenas com frases existentes
  no corpos do AC/DC; quando existiam, foram retirados os campos entre
  a palavra e o seu lema, de modo a uniformizar o n�mero de colunas do
  corpo, uma vez que nem todos os corpos fonte t�m o mesmo n�mero de
  campos/colunas. Deve usar-se em combina��o com o programa de teste
  acdc_pinta_corpo_teste.sh (ver sec��o 6. Programas).
 

4. Listas de exemplos de palavras de cor e de roupa
----------------------------

As listas de exemplos encontram-se organizadas por campo sem�ntico,
tipo de palavra (simples ou multi-palavra) e categoria gramatical:

cor.txt: palavras que designam nomes de cores
cor_A.txt: cores que s� s�o usadas como adjectivos
cor_V.txt: verbos que transmitem cor ou aus�ncia de cor
cor_mwe.txt: multi-palavras que designam nomes de cores 	

roupa_A.txt: adjectivos que modificam ou se aplicam a roupa
roupa_N.txt: nomes que designam roupas	
roupa_mwe.txt: nomes multi-palavra que designam roupas 

Para cada campo sem�ntico existe um ficheiro que classifica as
palavras desse campo sem�ntico em grupos:

Grupos_cor.txt: identifica os grupos de cor e as cores pertencentes a cada grupo
Grupos_roupa.txt: identifica os grupos de roupa e as roupas pertencentes a cada grupo

O campo sem�ntico da roupa inclui ainda um ficheiro de classes de
roupa (Classes_roupa.txt).


5. Regras de anota��o
---------------------

O pacote inclui:

- um ficheiro de regras de teste do programa corte-e-costura:

  - regras_corte-e-costura_cor_teste.txt: cont�m regras que ilustram a
    sintaxe das regras.

  Estas regras devem ser aplicadas a manta-de-retalhos_formatoregras
  usando o programa de teste acdc_corte-e-costura_teste.sh (ver sec��o
  6. Programas).


- cinco ficheiros de regras gen�ricas de teste do pacote (que se
  encontram na directoria regras) e cinco ficheiros de regras de teste
  exclusivas da manta-de-retalhos_fluxoregras (que se encontram na
  directoria do corpo):

  - regras_correccao_PALAVRAS_cor_teste.txt: exemplos de regras
    gen�ricas de teste que corrigem erros de anota��o

  - regras_positivas_cor_teste.txt: exemplos de regras gen�ricas de
    teste que adicionam informa��o relativa ao campo sem�ntico

  - regras_negativas_cor_teste.txt: exemplos de regras gen�ricas de
    teste que removem informa��o relativa ao campo sem�ntico

  - regras_especializacao_cor_teste.txt: exemplos de regras gen�ricas
    de teste que adicionam informa��o mais espec�fica sobre o campo
    sem�ntico

  - regras_recursivas_cor_teste.txt: exemplos de regras gen�ricas de
    teste que fazem modifica��es at� n�o haver novas modifica��es na
    anota��o

  - regras_correccao_PALAVRAS_cor_excl.txt: exemplos de regras
    exclusivas que corrigem erros de anota��o

  - regras_positivas_cor_excl.txt: exemplos de regras exclusivas que
    adicionam informa��o relativa ao campo sem�ntico

  - regras_negativas_cor_excl.txt: exemplos de regras exclusivas que
    removem informa��o relativa ao campo sem�ntico

  - regras_especializacao_cor_excl.txt: exemplos de regras exclusivas
    que adicionam informa��o mais espec�fica sobre o campo sem�ntico
  
  - regras_recursivas_cor_excl.txt: exemplos de regras exclusivas que
    fazem modifica��es at� n�o haver novas modifica��es na anota��o
  

  Estas regras devem ser aplicadas a manta-de-retalhos_fluxoregras
  usando o programa de teste acdc_pinta_corpo_teste.sh (ver sec��o
  6. Programas).

- dez ficheiros de regras gen�ricas (que se encontram na directoria
  regras), cinco para anota��o de cor e outros cinco para anota��o de
  roupa, com a vers�o actual, � data da distribui��o do pacote, que �
  usada na anota��o dos corpos do AC/DC:

  - regras_correccao_PALAVRAS_{cor|roupa}.txt: exemplos de regras
    gen�ricas que corrigem erros de anota��o

  - regras_positivas_{cor|roupa}.txt: exemplos de regras gen�ricas que
    adicionam informa��o relativa ao campo sem�ntico

  - regras_negativas_{cor|roupa}.txt: exemplos de regras gen�ricas que
    removem informa��o relativa ao campo sem�ntico

  - regras_especializacao_{cor|roupa}.txt: exemplos de regras
    gen�ricas que adicionam informa��o mais espec�fica sobre o campo
    sem�ntico

  - regras_recursivas_{cor|roupa}.txt: exemplos de regras gen�ricas
    que fazem modifica��es at� n�o haver novas modifica��es na
    anota��o


6. Programas 
------------

6.1 Requisitos

- Perl v5.8.8

6.2 Instala��o e utiliza��o

- Extrair o conte�do deste pacote para onde for pretendido

- Editar os ficheiros acdc_pinta_corpo.sh, acdc_pinta_corpo_teste.sh e
  acdc_corte-e-costura_teste.sh e modificar a vari�vel
  DIR_CORTECOSTURA para o caminho completo onde o corte-e-costura foi
  instalado

- Fazer a invoca��o dos programas a partir da directoria que cont�m o
  corpo que se pretende anotar.

6.3 Manual de utiliza��o

- O manual, ficheiro manual.html, encontra-se na directoria raiz do
  pacote corte-e-costura.

6.4 Licen�a

Todos os programas inclu�dos no pacote s�o distribu�dos com base na
licen�a BSD (ver LICENSE.txt).


7. Agradecimentos
-----------------

A Linguateca � financiada pelo governo portugu�s e pela Uni�o Europeia
(FEDER e FSE), no �mbito do contrato POSC/339/1.3/C/NAC, e pela FCCN e
pela UMIC.  Agradecemos � Ros�rio Silva pela cria��o das regras de
anota��o da cor e tamb�m por ter iniciado a cria��o das regras de
anota��o da roupa, e ao Fernando Ribeiro pelos in�meros testes que
executou com o pacote.


------------------------------------------
Data de actualiza��o do presente ficheiro: 25 de Agosto de 2010
------------------------------------------
