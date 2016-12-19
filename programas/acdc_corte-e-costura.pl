#!/usr/bin/perl -w

# $HeadURL: file:///Users/cmota/data/packs/linguateca/svn-acdc/acdc_corte-e-costura.pl $
# $LastChangedDate: 2010-07-28 01:38:59 -0400 (Qua, 28 Jul 2010) $
# $LastChangedRevision: 59 $
# $LastChangedBy: cmota $
# $Id: acdc_corte-e-costura.pl 59 2010-07-28 05:38:59Z cmota $

# A corrigir:
# -- ordem de aplicação das regras

use POSIX qw(strftime);
use POSIX qw(locale_h); 
setlocale(LC_CTYPE, "pt_PT");    
use locale;

############### RECURSAO ##################

## Análise dos argumentos do programa

if (@ARGV == 0 || $ARGV[0] eq "-h") { print <<FIM;

ACDC_CORTE-E-COSTURA 1.0
Programa para aplicar regras de anotação de cor a um corpo no formato AC/DC.


Chamada: 

$0 -h 
$0 -r FICH_REGRAS -p POSICAO [-l LOG] [-i RECURSAO] [-d DEPURAR] [-a AVISAR] [CORPO] 

Argumentos: 

FICH_REGRAS é o nome do ficheiro que contém as regras que vão ser aplicadas ao corpo
CORPO nome do ficheiro com o corpo a que vão ser aplicadas as regras; também pode ser lido do STDIN se CORPO não foi dado
POSICAO onde se encontra o lema: 5 para o ConDiv, 3 para o ENPCPUB
LOG nome do ficheiro para escrever um registo de aplicação das regras
RECURSAO [0|1] com valor 1 repete a aplicação das regras à frase até não haver diferenças; com 0 ou omitindo o parâmetro aplica as regras a cada frase apenas uma vez
DEPURAR [0|1] com o valor 1 escreve no ficheiro de registo o formato interno de todas as regras que foram lidas do ficheiro de regras; se for 0 ou estiver omitido não regista a representação interna.
AVISAR [0|1] com o valor 1 escreve no ficheiro de registo mensagens de aviso de possíveis conflitos entre as regras.


                                Cristina Mota, 28 de Julho de 2010

FIM
exit;
}
else{
    for ($i = 0; $i < @ARGV; $i=$i+2) {
	$fich_regras = $ARGV[$i+1] if $ARGV[$i] =~ /-r/;
	$posicao = $ARGV[$i+1] if $ARGV[$i] =~ /-p/;
	$log = $ARGV[$i+1] if $ARGV[$i] =~ /-l/;
	$recursao = $ARGV[$i+1] if $ARGV[$i] =~ /-i/;
	$depurar = $ARGV[$i+1] if $ARGV[$i] =~ /-d/;
	$avisar = $ARGV[$i+1] if $ARGV[$i] =~ /-a/;
    }
    unless ($fich_regras){ die "O ficheiro de regras (-r) não foi fornecido.\n" };
    unless ($posicao){ die "A posição (-p) não foi fornecida.\n" };

    %indices_atributos = ( word => 0,
	                   lema => $posicao,
			   pos => $posicao + 1,
			   temcagr => $posicao + 2,
			   pessnum => $posicao + 3,
			   gen => $posicao + 4,
			   func => $posicao + 5,
			   deriv => $posicao + 6,
			   sema => $posicao + 7,
			   grupo => $posicao + 8);
    
    if (@ARGV % 2 == 0) {
	$ARGV[0]="-";
	$#ARGV=0;
	print STDERR "Corpo: STDIN; Regras: $fich_regras; Posicao do lema: $posicao\n";
    }
    else{    
	$ARGV[0]=$ARGV[$#ARGV];
	$#ARGV=0;
	print STDERR "Corpo: $ARGV[0]; Regras: $fich_regras; Posicao do lema: $posicao\n";
    }
}

sub regista_mensagem{
    print {$log ? LOG : STDERR} $_[0];
}

sub actualiza_posicional{
#    print STDERR "A: $atomos[$atomo+$posicao] $valor\n";
    if($atomos[$atomo+$posicao] =~ /^(([^\t]+\t){$tamanho})[^\t]+([\t\n])/){
	$atomos[$atomo+$posicao] =~ s/^(([^\t]+\t){$tamanho})[^\t\n]+([\t\n])/$1$valor$3/;
    }
    else{
	$atomos[$atomo+$posicao] =~ s/(\n<\/mwe>|$)/\t$valor$1/;
     }
#    print STDERR "D: $atomos[$atomo+$posicao] $valor\n";
}

sub actualiza_estrutural{
    if($atomos[$atomo+$posicao] =~ / $atributo=/){
	$atomos[$atomo+$posicao] =~ s/$atributo=("?)([^"\s\n>]+("?))/$atributo=$1$valor$3/;
    }
    else{
	$atomos[$atomo+$posicao] =~ s/>$/ $atributo="$valor">/;
    }
    if( $valor eq "0" and $atributo eq "sema" and $atomos[$atomo+$posicao] !~ / grupo="?0"?/ and $consequente !~ /grupo="0"/){
	if( $atomos[$atomo+$posicao] =~ / grupo/ and $avisar){
	    regista_mensagem "AVISO: a unidade na posição $. ficou com sema=\"0\" mas grupo é não vazio.\n";
	}
    }
}

sub verifica_estrutural{
    ($atributo,$valor) = ($_[1] =~ /<($ATRIBUTO)="($VALOR)">/);
    return ($atributo ? $_[0] =~ / $atributo="?$valor"?[> ]/ : 0);
}

sub normaliza_antecedente{
    %referencias=();
    @novo_componente=();
    $ntermos=0; 
    while ($antecedente =~ /([a-z]?):?((\[$PAR_AV( +& +$PAR_AV)*\])|(<\/?(mwe)?( *$PAR_AV)*>)|(\*))/g){
	if( $1 ){
	    if( exists $referencias{$1} ){
		print STDERR "Erro na linha $. no consequente da regra: $regra. A referência $9: já existe no antecedente\n";
		$haerros = 1;
	    }
	    else{
		$referencias{$1}=$ntermos; 
	    }
	}
	$termo = $2;
	$termo =~ s/ +& +/] ${ntermos}[/g if $termo =~ /^\[/;
	$termo =~ s/ +/> ${ntermos}</g if $termo =~ /^\</;
	$termo =~ s/^/$ntermos/;
	$termo =~ s/<mwe>/<mwe.*>/;
	$termo =~ s/\-/\\-/g;
#	$termo =~ s/"//g if $termo =~ /\d</;
#	print STDERR "$termo\n";
	push @novo_componente, $termo;
	$ntermos++;
    }
    if (! keys %referencias){
#	$referencias{"A"} = 
    }
    return join(" ",@novo_componente);
}

sub normaliza_consequente{
    @novo_componente=();
    $ntermos=0;
    $posicao=0;
#    while ($consequente =~ /(<(mwe( +$ATRIBUTO=\"$VALOR\")*)> *([a-z]):( *([a-z]:))* *([a-z]): *<\/mwe>)|(([a-z]?):?((\[$PAR_AV( +\& +$PAR_AV)*\])|(<$PAR_AV( +$PAR_AV)*>)|(<\/mwe>)))/g){
    while ($consequente =~ /(<(mwe( +$ATRIBUTO=\"$VALOR\")*)> *([a-z]):(( *([a-z]:))* *([a-z]):)? *<\/mwe>)|(([a-z]?):?((\[$PAR_AV( +\& +$PAR_AV)*\])|(<$PAR_AV( +$PAR_AV)*>)|(<\/mwe>)))/g){
	if($1){
	    $primeiro = $referencias{$4};
	    if( $8 ){
		$ultimo = $referencias{$8};
	    }
	    else{
		$ultimo = $referencias{$4};
	    }
	    $estrutural = $2; 
	    #$estrutural =~ s/ +/> ${primeiro}</g;
	    push @novo_componente, "${primeiro}<$estrutural> ${ultimo}</mwe>";
	}
	else{
	    if( $10 and !exists $referencias{$10}){
		print STDERR "Erro na linha $. na regra: $regra. A referência $10: usada no consequente não existe no antecedente.\n";
		$posicao = -1;
		$haerros = 1;
	    }
	    else{
		$posicao = ($10 ? $referencias{$10} : 0);
	    }
	    $termo = $11;
	    $termo =~ s/^/$posicao/;
	    $termo =~ s/ +& +/] ${posicao}[/g if $termo =~ /\d\[/;
	    $termo =~ s/ +/> ${posicao}</g if $termo =~ /\d</;
#	    $termo =~ s/"//g if $termo =~ /\d</;
	    $termo =~ s/\-/\\-/g;
	    push @novo_componente, $termo;
	}

    }
    return join(" ",@novo_componente);
}

# Devolve a posição do último termo do antecedente caso a regra seja activada, senão devolve 0. 
sub aplica_regra{
    $mwe=0;
    %mapa_posicoes=();
    $regra_disparou=1;
    $comprimento_mwe=0; # só pode ser zero uma vez por cada regra que está a ser aplicada porque pode haver mais do que um <mwe> de comprimento indeterminado;
                        # além disso, no fim de aplica_regra o seu valor vai ser usado por executa_consequente (de outra forma a posição das referências não é actualizada)
    while($antecedente =~ /((\d+)(([<\[][^\[\]<>]+[>\]])|(\*)))/g and $regra_disparou){
	$tudo = $1;
	$posicao = $2+$comprimento_mwe; 
	$mapa_posicoes{$2} = $posicao;
	$pav = $3;
	# O texto ainda tem comprimento suficiente para aplicar a regra?
	if(($atomo+$posicao) >= 0 and ($atomo+$posicao) < @atomos){
	    # Se a unidade ou termo da regra são estruturais então são iguais? 
	    if($pav =~ /<[^>]+>/ and $atomos[$atomo+$posicao] =~ /<[^>]+>/){
		if($atomos[$atomo+$posicao] =~ /$pav/){
		    $mwe=1;
		}
		elsif( !verifica_estrutural $atomos[$atomo+$posicao], $pav){
		    $regra_disparou = 0;
		}
	    }
	    elsif( $tudo =~ /(\d+)\[($ATRIBUTO)="($VALOR)"\]/){
		$posicao = $1 + $comprimento_mwe;
		$atributo = $2;
		$valor = $3;
		$tamanho=$indices_atributos{$atributo};
		if(!defined $tamanho){
		    print STDERR "AVISO: o índice do campo '$atributo' é desconhecido na regra $antecedente >> $consequente.\n";
		    $regra_disparou=0;
		}
		else{
		    $regra_disparou=0 unless $atomos[$atomo+$posicao] =~ /^(([^\t]+\t){$tamanho})($valor)[\t\n]/ and $atomos[$atomo+$posicao] =~ /^[^<]/;
		}
	    }
	    elsif( $tudo =~ /^(\d)\*$/ and $mwe and $regra_disparou){
		$posicao = $1 + $comprimento_mwe;
		while($atomos[$atomo+$posicao] !~ /<\/mwe>/ and ($atomo+$posicao) < @atomos){
		    $comprimento_mwe++;
		    $posicao++;
		}
		if( $atomos[$atomo+$posicao] =~ /<\/mwe>/){
		    $comprimento_mwe--;
		}
		else{
		    $regra_disparou = 0;
		}
		$mwe=0;
	    }
	    else{
		$regra_disparou = 0;
	    }
	}
	else{
	    $regra_disparou = 0;
	}
    }
    if( $regra_disparou ){
	$regra_disparou = $posicao+1;
    }
}

sub executa_consequente{
    $mwe_existe = -2;
    while($consequente =~ /((\d+)([<\[][^\[\]<>]+[>\]]))/g){
	$tudo = $1;
	$posicao = $mapa_posicoes{$2}; # o mapa de posições é criado em aplica_regra;
	$pav = $3;
	## Esta forma de inserir os compostos não é a melhor, pois insere na unidade o marcador, em vez de criar
	## uma nova entrada em @atomos que corresponde ao novo marcador inserido.
	if($pav =~ /<mwe(.*)>/){
	    $mwe_atributos = $1;
	    if( $atomos[$atomo+$posicao-1] =~ /^<mwe/ ){
		$mwe_existe = $posicao-1;
	    }
	    else{
		$atomos[$atomo+$posicao] =~ s/^/$pav\n/ unless $atomos[$atomo+$posicao] =~ /^<mwe/;
	    }
	}
	elsif($pav =~ /<\/mwe>/){
	    if($mwe_existe > -2 ){
		if($atomos[$atomo+$posicao+1] =~ /<\/mwe>/ or $atomos[$atomo+$posicao] =~ /<\/mwe>/){
		    $posicao= $mwe_existe;
		    while($mwe_atributos =~ /($ATRIBUTO)="($VALOR)"/g){
			$atributo = $1;
			$valor = $2;
			actualiza_estrutural;
		    }
		    regista_mensagem "AVISO: O consequente da regra $antecedente >> $consequente foi executado em modo de fusão porque a mwe já existe.\n" if $avisar;
		}
		else{
		    $atomos[$atomo+$mwe_existe+1] =~ s/^/<mwe$mwe_atributos>\n/;
		    $atomos[$atomo+$posicao] =~ s/$/\n<\/mwe>/;
		}
	    }
	    else{
		$atomos[$atomo+$posicao] =~ s/$/\n<\/mwe>/ unless $atomos[$atomo+$posicao+1] =~ /<\/mwe>/ or $atomos[$atomo+$posicao] =~ /<\/mwe>/;
	    }
	    $mwe_existe=-2;
	}
	else{
	    if( $tudo =~ /(\d+)([<\[])($ATRIBUTO)="($VALOR)"[>\]]/){
		$posicao = $mapa_posicoes{$1};
		$tipo = $2;
		$atributo = $3;
		$valor = $4;
		if( $tipo =~ /</){
		    actualiza_estrutural;
		}
		else{		
		    $tamanho=$indices_atributos{$atributo};
		    actualiza_posicional;
		    $tamanho++;
		    if( $valor eq "0" and $atributo eq "sema" and $atomos[$atomo+$posicao] !~ /^(([^\t]+\t){$tamanho})0[\t\n]/ and $consequente !~ /grupo="0"/){
			if($atomos[$atomo+$posicao] !~ /^(([^\t]+\t){$tamanho})\n/ and $avisar){
			    regista_mensagem "AVISO: a unidade na posição $. ficou com sema=\"0\" mas grupo é não vazio.\n";
			}
		    }
		}
	    }
	}
	$atomos[$atomo+$posicao] =~ s/$/\n/ unless  $atomos[$atomo+$posicao] =~ /\n$/;
    }
}

sub processa_frase{
    $atomo=0;
    while($atomo < @atomos) {
	$posicao_em_fich_original=$em_frase+$atomo;
	for($r=0; $r<$nregras; $r++){
	    $antecedente=$antecedentes[$r];
	    $consequente=$consequentes[$r];
	    $regra_disparou = aplica_regra $antecedente; 
	    if( $regra_disparou ){
		regista_mensagem "Na posição ${posicao_em_fich_original} disparou a regra: $antecedente >> $consequente.\n";
		executa_consequente $consequente;
	    }
	}
	$atomo++;
    }
    return join("",@atomos);
}


## Inicialização do ficheiro LOG

if($log){
    open(LOG, ">", $log) or die "Não consegui abrir o ficheiro para escrever mensagens de aplicação de regras $log \n";
}
$Rev="Rev";
$LastChangedDate="Data da última alteração";
$dummy ="";
regista_mensagem "## -------\n## Ficheiro de registo do programa acdc_corte-e-costura.pl\n## $Rev: 59 $dummy $LastChangedDate: 2010-07-28 01:38:59 -0400 (Qua, 28 Jul 2010) $dummy\n## -------\n";


## Lê o ficheiro regras
$COMENTARIO = "#";
$SEPARADOR = ">>";
$ATRIBUTO = "[a-z]+";
$VALOR = "[^\"]+";
$PAR_AV = "$ATRIBUTO=\"$VALOR\"";
#$MARCADOR = "<\/?(mwe)?(<\/?(mwe)?( *$PAR_AV)*>)>";
$TERMOA = "([a-z]:)?((\[$PAR_AV( +& +$PAR_AV)*\])|(<\/?(mwe)?( *$PAR_AV)*>)|(\\*))";
$TERMOC = "([a-z]:)?((\[$PAR_AV( +& +$PAR_AV)*\])|(<$PAR_AV( +$PAR_AV)*>)|(<\/mwe>))";

@indice_antecedentes=();
@antecedentes=[];
@consequentes=[];
$nregras=0;
$haerros=0;
open(REGRAS, $fich_regras) or die "Não consegui abrir o ficheiro de regras $fich_regras \n";
while (<REGRAS>) {
    if(!/^ *$COMENTARIO/){
	$_ =~ s/([^\\])$COMENTARIO.*$/$1/;
	$regra = $_;
	$regra =~ s/\\$COMENTARIO/$COMENTARIO/;
	$regra =~ s/ *\n//;
	if( ($antecedente, $consequente) = ($_=~/^(.+) $SEPARADOR +(.+)/)){
	    if ($antecedente =~ /^ *$TERMOA( +$TERMOA)* *$/ and ($consequente =~ /^$TERMOC( +$TERMOC)* *$/ 
							       or $consequente =~ /<mwe( +$ATRIBUTO=\"$VALOR\")*>(( *[a-z]: *)+)<\/mwe>/)){
		$antecedente = normaliza_antecedente $antecedente;
		$consequente = normaliza_consequente $consequente;
		if( $indice_antecedentes{$antecedente} ){
		    regista_mensagem "AVISO: O antecedente da regra $antecedente >> $consequente é igual ao da regra $indice_antecedentes{$antecedente}.\n" if $avisar;
		}
		else{
		    $indice_antecedentes{$antecedente}=$nregras;
		}
		$antecedentes[$nregras]=$antecedente;
		$consequentes[$nregras]=$consequente;
		regista_mensagem "$antecedente >> $consequente\n" if $depurar;
		$nregras++;
	    }
	    else{
		print STDERR "Erro na linha $. na regra: $regra.\n";
		$haerros = 1;
	    }
	}
	else{
	    if(/^ *[^\s]+( +[^\s]+)+ *$/){
		$_ =~ s/ +/ /g;
#	    print ">>", $_,"\n";
		@constituintes = split(/\s/,$_);
		@antecedente = ();
		#a:[lema="peito"] b:[lema="de"] c:[lema="rola"] >> <mwe lema="peito=de=rola" sema="cor"> a:[sema="cor"] b: c: </mwe>
		$lema = join("=",@constituintes);
		if(!$sema){
		    die "O campo semântico não está definido.\n";
		}
		$consequente = "0<mwe lema=\"$lema\" pos=\"$pos\" sema=\"$sema\"> $#constituintes</mwe> 0[sema=\"$sema\"]";
		$posicao=0;
		foreach(@constituintes){
		    push @antecedente, "${posicao}[lema=\"$_\"]";
		    $posicao++;
		} 
		$antecedente = join(" ",@antecedente );
		if( $indice_antecedentes{$antecedente} ){
		    regista_mensagem "AVISO: O antecedente da regra $antecedente >> $consequente é igual ao da regra $indice_antecedentes{$antecedente}.\n" if $avisar;
		}
		else{
		    $indice_antecedentes{$antecedente}=$nregras;
		}
		$antecedentes[$nregras]=$antecedente;
		$consequentes[$nregras]=$consequente;
		regista_mensagem "$antecedente >> $consequente\n" if $depurar; 
		$nregras++;
	    }
	    elsif(!/^ *\n$/) {
		print STDERR "Erro na linha $. na regra: $regra\n";
		$haerros = 1;
	    }
	}
    }
    elsif(/^ *$COMENTARIO *sema=(.*) +pos=([^#\n]+)/){
	$sema=$1;
	$pos=$2;
    }
}
if ($haerros) {
    die "O programa não foi executado porque o ficheiro de regras tem erros.\n";
}
print STDERR "Número de regras lidas: $nregras\n";
regista_mensagem "## -------\n" if $depurar;
close(REGRAS);


# die "Fim do teste\n";


## Aplica as regras
$now_string = strftime "%e %b %Y, %H:%M:%S", localtime;
regista_mensagem "## Hora de início: $now_string\n\n";

while (<>) {
    if (/^<s/ and !$em_frase ) {
	@atomos = ();
	$em_frase = $.;
    }
    if($em_frase){
	push @atomos, $_;
    }
    else{
	print;
    }
    if (/^<\/s>/ and $em_frase) {
	$resultado_mudou=1;
	$estado_anterior = join("",@atomos);
	while($resultado_mudou){
	    $novo_estado = processa_frase;
	    $resultado_mudou = !($estado_anterior eq $novo_estado);
	    if( $resultado_mudou ){
		$estado_anterior = $novo_estado;
	    }
	    else{
		$resultado_mudou = 0;
	    }
	    $resultado_mudou=0 unless $recursao;
#	    print STDERR $novo_estado," ";
#	    @atomos = split(/\n/,$novo_estado);
#	    print STDERR $novo_estado, "\n" if $resultado_mudou;
	}
	foreach $atomo (@atomos){
	    print $atomo;
	}
	$em_frase = 0;
    }
}

$now_string = strftime "%e %b %Y, %H:%M:%S", localtime;

regista_mensagem "\n## Hora de fim: $now_string\n";

if($log){ 
    close(LOG) 
};
