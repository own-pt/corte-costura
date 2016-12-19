# programa que aplica as regras de anotação semântica aos corpos
# DMS; 5 de Janeiro de 2010
# CM; 16 de Agosto de 2010
#
# Recebe um valor (obrigatório) para profundidade que indica a posição
# (ou seja, a coluna) do lema no corpo.
# Além desse, recebe um valor opcional -p, que indica que o teste deve
# ser corrido gerando a cada passo o corpus temporário resultante desse
# passo.
# 
# Exemplos: 
#    acdc_pinta_corpo_teste "1" 
#    acdc_pinta_corpo_teste "1" -p
#

export DIR_CORTECOSTURA=/Users/arademaker/work/corte-e-costura-1.0

cat $DIR_CORTECOSTURA/regras/regras_corr_PALAVRAS_cor_teste.txt regras_corr_PALAVRAS_cor_excl.txt > corr_PALAVRAS.txt
cat $DIR_CORTECOSTURA/regras/regras_especializacao_cor_teste.txt regras_especializacao_cor_excl.txt > especializacao.txt
cat $DIR_CORTECOSTURA/regras/regras_recursivas_cor_teste.txt regras_recursivas_cor_excl.txt > recursivas.txt

echo "ACDC_PINTA_CORPO com profundidade $1: resultado em corpus_cor"

if [[ $2 == "-p" ]]; then
# Além do corpo final, cria sete corpos temporários (um por cada passo) e cinco ficheiros de log diferentes
# log_regras_corr
# log_regras_mwe
# log_regras_positivas
# log_regras_negativas
# log_regras_recur

    cat $DIR_CORTECOSTURA/regras/regras_positivas_cor_teste.txt regras_positivas_cor_excl.txt > positivas.txt
    cat $DIR_CORTECOSTURA/regras/regras_negativas_cor_teste.txt regras_negativas_cor_excl.txt > negativas.txt

    cat corpus | $DIR_CORTECOSTURA/programas/acdc_corte-e-costura.pl -r corr_PALAVRAS.txt -p $1 -l log_regras_corr > corpus_tmp_corr_PALAVRAS

    cat corpus_tmp_corr_PALAVRAS | $DIR_CORTECOSTURA/programas/acdc_corte-e-costura.pl -r $DIR_CORTECOSTURA/lexicos/mwe.txt -p $1 -l log_regras_mwe > corpus_tmp_mwe

    cat corpus_tmp_mwe | $DIR_CORTECOSTURA/programas/acdc_alinhavo.pl  -i -n $1 > corpus_tmp_campos_sema

    cat corpus_tmp_campos_sema | $DIR_CORTECOSTURA/programas/acdc_corte-e-costura.pl -r positivas.txt -p $1 -l log_regras_positivas > corpus_tmp_positivas

    cat corpus_tmp_positivas | $DIR_CORTECOSTURA/programas/acdc_corte-e-costura.pl -r negativas.txt -p $1 -l log_regras_negativas > corpus_tmp_negativas

    cat corpus_tmp_negativas | $DIR_CORTECOSTURA/programas/acdc_corte-e-costura.pl -r especializacao.txt  -p $1 -l log_regras_especializacao > corpus_tmp_especializacao

    cat corpus_tmp_especializacao | $DIR_CORTECOSTURA/programas/acdc_corte-e-costura.pl -r recursivas.txt -p $1 -l log_regras_recur -i sim  > corpus_tmp_recursivas

    cat corpus_tmp_recursivas | $DIR_CORTECOSTURA/programas/acdc_remate.pl -n $1 > corpus_cor
else
# Cria o corpo final e quatro ficheiros de log diferentes
# log_regras_corr
# log_regras_mwe
# log_regras_depois
# log_regras_espec
# log_regras_recur
    cat $DIR_CORTECOSTURA/regras/regras_positivas_cor_teste.txt regras_positivas_cor_excl.txt  $DIR_CORTECOSTURA/regras/regras_negativas_cor_teste.txt regras_negativas_cor_excl.txt > outras_regras.txt


    cat corpus | $DIR_CORTECOSTURA/programas/acdc_corte-e-costura.pl -r corr_PALAVRAS.txt -p $1 -l log_regras_corr | $DIR_CORTECOSTURA/programas/acdc_corte-e-costura.pl -r $DIR_CORTECOSTURA/lexicos/mwe.txt -p $1 -l log_regras_mwe | $DIR_CORTECOSTURA/programas/acdc_alinhavo.pl  -i -n $1 | $DIR_CORTECOSTURA/programas/acdc_corte-e-costura.pl -r outras_regras.txt -p $1 -l log_regras_depois  |  $DIR_CORTECOSTURA/programas/acdc_corte-e-costura.pl -r especializacao.txt  -p $1 -l log_regras_espec | $DIR_CORTECOSTURA/programas/acdc_corte-e-costura.pl -r recursivas.txt -p $1 -l log_regras_recur -i sim  | $DIR_CORTECOSTURA/programas/acdc_remate.pl -n $1 > corpus_cor
fi;
