# Programa que aplica as regras de teste do corte-e-costura
# CM; 16 de Agosto de 2010
#
# Recebe um parâmetro opcional que deve ter o valor -r quando se pretende fazer o teste com recursão. O programa corte-e-costura é corrido com as mensagens de aviso activadas (opção -a 1).
#
# Exemplo com recursão: acdc_corte-e-costura_teste.sh -r
# Exemplo sem recursão: acdc_corte-e-costura_teste.sh
#
# cria o ficheiro de log: log_regras_teste


export DIR_CORTECOSTURA=/Users/arademaker/work/corte-e-costura-1.0

echo "ACDC_CORTE-E-COSTURA_TESTE com profundidade 1: resultado em corpus_cor"

cat 12166-edited.conllu | $DIR_CORTECOSTURA/programas/acdc_corte-e-costura.pl -r regra.txt -p 1 -l log_regras_teste -i 1 -a 1 > 12166-annotated.txt

