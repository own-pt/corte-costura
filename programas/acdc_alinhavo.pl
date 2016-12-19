#!/usr/bin/perl -w
use POSIX qw(locale_h); 
setlocale(LC_CTYPE, "pt_PT");    
use locale; 
use Cwd;

if ($ARGV[0] eq "-h") { print <<FIM;

ACDC_POE_CAMPO_SEMANTICO
Programa para juntar na mesma passagem os atributos semânticos "sema" quer a 
um corpo em formato AC/DC quer a uma lista de lemas
Lê todos os ficheiros da forma cor*.txt e roupa*.txt que estejam na 
directoria $ENV{'DIR_CORTECOSTURA'}/lexicos

Chamada: 

$0 [-h | [-i | -m] -n tamanho] < fich_entrada > fich_saída

Opções: 

-i indica que é o início de uma anotação
-m indica que é para modificar o que já está

-n posição onde se encontra o lema: 5 para o ConDiv, 3 para o ENPCPUB, 
1 para listas de lemas


                                DMS, 14 de Dezembro de 2009

FIM
exit;
} elsif ($ARGV[0] eq "-i") {
    $iniciar=1; shift;
} elsif ($ARGV[0] eq "-m") {
    $modificar=1; shift;
} else {
 print "O programa deve ser invocado com as opções -i ou -m\n";
 exit;
}
    shift;
    $tamanho=$ARGV[0];
    print STDERR "tamanho $tamanho\n";
    shift;

$dir_sem="$ENV{'DIR_CORTECOSTURA'}/lexicos";
chdir ($dir_sem);
print STDERR "Na directoria $dir_sem\n";

while ($fich_sem=<cor.txt cor_[A-Z].txt roupa_[A-Z].txt>) {

#    $fich_sem=$ARGV[0];
    $camp_sem=$fich_sem;
    $camp_sem=~s/\.txt//;
    $camp_sem=~s/^.*\///;
    $camp_sem=~s/_(.*)$//;
    $restricao=$1;
    if (not $restricao) {
	$restricao=".";
    }


#lê os valores do atributo semântico
    open(SEM, $fich_sem) or die "Não consegui abrir o ficheiro $fich_sem \n";
    while(<SEM>) {
	($nome_sem)=($_=~m/^(\w[\w\- ]+?)\s*$/);

	if ($nome_sem) {
	    $$camp_sem{$nome_sem}=1;
	    $restricao{$nome_sem}=$restricao;
#	    print "$nome_sem; $camp_sem; $restricao\n";
	}
    }
    close(SEM);
    print STDERR "Li o ficheiro $fich_sem\n";

}


# Agora ataca o ficheiro que se quer anotar
$em_mwe=0;
$num_mwe=-10;

while (<>) {
    foreach $camp_sem ("cor","roupa") {
	if (/^</) {
#	    print;
# é preciso evitar que as mwe sejam marcadas mais de uma vez
	    if (/^<mwe.* sema=\"$camp_sem/) {
		$num_mwe=0;
		$em_mwe=1;
	    }
	    if (/^<\/mwe/) {
		$em_mwe=0;
		$num_mwe=-10;
	    }
	} else {
	    ($lema)=(m/^(?:[^\t]*?\t){$tamanho}([^\t]*?)(\t|\n)/);  
#	    print STDERR "Lema : $lema\n";
	    $num_mwe++ if ($em_mwe);
#	    print STDERR "$num_mwe\n";
	    if ($lema and exists $$camp_sem{$lema} and not /\tPROP\t/ and not /\t$camp_sem$/ and ($num_mwe le 2)) {
#		print STDERR "lema: $lema; $$camp_sem{$lema}, $restricao{$lema}\n";
		s/^((?:[^\t]*?\t){$tamanho}([^\t]*?)\t$restricao{$lema}.*\t.*)\n$/$1\t$camp_sem\n/ if ($iniciar);
#	    s/\n$/\t$camp_sem\n/ if ($iniciar);
	    }
	}

    }
    print;
}


