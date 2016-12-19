# programa que aplica as regras de anotação semântica aos corpos
# DMS; 5 de Janeiro de 2010
# CM; 16 de Agosto de 2010
#
# Recebe um valor (obrigatório) para profundidade que indica a posição
# (ou seja, a coluna) do lema no corpo, e outro (opcional) para um sufixo 
# no nome do corpo
# Exemplo: acdc_pinta_corpo "5" "_saude_br"
#
# cria quatro ficheiros de log diferentes
# log_regras_corr
# log_regras_mwe
# log_regras_depois
# log_regras_espec
# log_regras_recur

export DIR_CORTECOSTURA=/Users/arademaker/work/corte-e-costura-1.0

cat $DIR_CORTECOSTURA/regras/regras_corr_PALAVRAS_[cr]*.txt regras_corr_PALAVRAS$2_[cr]*_excl.txt > corr_PALAVRAS.txt
cat $DIR_CORTECOSTURA/regras/regras_positivas_[cr]*.txt regras_positivas$2_[cr]*_excl.txt  $DIR_CORTECOSTURA/regras/regras_negativas_[cr]*.txt regras_negativas$2_[cr]*_excl.txt > outras_regras.txt

cat $DIR_CORTECOSTURA/regras/regras_especializacao_[cr]*.txt regras_especializacao$2_[cr]*_excl.txt > especializacao.txt
cat $DIR_CORTECOSTURA/regras/regras_recursivas_[cr]*.txt regras_recursivas$2_[cr]*_excl.txt > recursivas.txt

echo "ACDC_PINTA_CORPO com profundidade $1: resultado em corpus$2_cor"

cat corpus$2 | $DIR_CORTECOSTURA/programas/acdc_corte-e-costura.pl -r corr_PALAVRAS.txt -p $1 -l log_regras_corr | $DIR_CORTECOSTURA/programas/acdc_corte-e-costura.pl -r $DIR_CORTECOSTURA/lexicos/mwe.txt -p $1 -l log_regras_mwe | $DIR_CORTECOSTURA/programas/acdc_alinhavo.pl  -i -n $1 | $DIR_CORTECOSTURA/programas/acdc_corte-e-costura.pl -r outras_regras.txt -p $1 -l log_regras_depois  |  $DIR_CORTECOSTURA/programas/acdc_corte-e-costura.pl -r especializacao.txt  -p $1 -l log_regras_espec | $DIR_CORTECOSTURA/programas/acdc_corte-e-costura.pl -r recursivas.txt -p $1 -l log_regras_recur -i sim  | $DIR_CORTECOSTURA/programas/acdc_remate.pl -n $1 > corpus$2_cor

