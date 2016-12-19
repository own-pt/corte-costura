#!/usr/bin/perl
use POSIX qw(locale_h); 
setlocale(LC_CTYPE, "pt_PT");    
use locale; 

if ($ARGV[0] eq "-h") { print <<FIM;

ACDC_POE_GRUPOS_SEMA
Programa para juntar automaticamente o grupo de um dado atributo do sema,
depois de ler os ficheiros que se encontram na directoria referente aos
campos semânticos

Por agora faz também: 
para o campo cor, transforma "tinto" em cor:vinho, 
as palavras de cor de pele ou cabelo em cor:humana, no atributo "sema".

Cria um ficheiro "erros" que é preciso apagar depois de ver...

Chamada: 
 $0 [-h | -n tamanho]

Opções:
-n posição onde se encontra o lema no corpo AC/DC: 5 para o ConDiv, 
3 para o ENPCPUB, 

                                      DMS, 3 de Julho de 2010

FIM
exit;
} elsif ($ARGV[0] eq "-n") {

    shift;
    $tamanho=$ARGV[0];
    print STDERR "tamanho $tamanho\n";
    shift;
}

%plural=("cor", "Cores", "roupa", "Roupas");

$dir_sem="$ENV{'DIR_CORTECOSTURA'}/lexicos";
chdir ($dir_sem);
print STDERR "Na directoria $dir_sem\n";

while ($fich_grupos=<Grupos_cor.txt Grupos_roupa.txt Classes_roupa.txt>) {

    $campsem=$fich_grupos;
    $campsem=~s/\.txt//;
    $campsem=~s/^.*\///;
    $campsem=~s/(Grupos|Classes)_//;
#    print STDERR "Campo semântico associado a $fich_grupos: $campsem\n";

#lê a lista dos grupos, criando dois vectores associativos: %grupocor e %gruporoupa

    open(GRUPOS, $fich_grupos) or die "Não consegui abrir o ficheiro $fich_grupos\n";
    $nomegrupo="grupo$campsem";
    while(<GRUPOS>) {
	($nome_grupo, $lista)=($_=~m/^(\w+): (.*?)\.*\s*$/);
	@casos=split(/, /,$lista);
	foreach $caso (@casos) {
	    if ($caso=~m/ /) {
		$caso=~s/ /=/g;
#	    print "$caso de $nome_grupo\n";
	    }
	    if ($nome_grupo) {
		if ($$nomegrupo{$caso}) {
		    $$nomegrupo{$caso}.="_".$nome_grupo;
		} else {
		    $$nomegrupo{$caso}=$nome_grupo;
		}
	    }
#	    print "$caso de $nome_grupo: $$nomegrupo{$caso}, $nomegrupo\n";
	}
    }
    close(GRUPOS);
    print STDERR "Li o ficheiro $fich_grupos para o $nomegrupo\n";
}

# aqui retirar o _ antes do primeiro grupo de cada caso?

open(ERROS, ">erros") or die "Não consigo abrir o ficheiro erros!";
$num_casos=0;
$grupo_mwe="";

while (<>) {

    s/\r//g; # também tira os ^M
    chop();
    $sema_final=$grupo_final="";
    foreach $sema ("cor","roupa") {
#	print STDERR "Estou no campo $sema...\n";
	$nomegrupo="grupo$sema";
	if (/^\s*</ or /^ABR/) { # se for atributo estrutural
	    if (/<mwe.* sema=\"$sema\"/) {
		s/<mwe (.*)lema=\"(.*?)\"(.*) sema=\"$sema\"/<mwe lema=\"$2\" $1$3 grupo=\"$$nomegrupo{$2}\" sema=\"$sema\"/;
		$grupo_mwe{$sema}=$$nomegrupo{$2};
#		print STDERR "MWE: $2, $$nomegrupo{$2}\n";
		if ($grupo_mwe{$sema}=~/Original/){
		    s/grupo=.*? sema=\"$sema/sema=\"$sema:original/;
		}
		if ($grupo_mwe{$sema}=~/Humana/){
		    s/grupo=.*? sema=\"$sema/sema=\"$sema:humana/;
		}
		if ($grupo_mwe{$sema}=~/Raça/){
		    s/grupo=.*? sema=\"$sema/sema=\"$sema:raça/;
		}

	    }
	} elsif (not /^\s*$/) { # se não for linha vazia

	    ($lema,$suf,$alts)=(m/^(?:[^\t]*?\t){$tamanho}(.+?)\t.*\t$sema(:.*)*(_.*?)*\s*$/);  
	    if ($alts) {
		print STDERR "$alts: Há vagueza aqui: $_\n";
	    }
	    if ($lema) {
#		print "palavra do campo $sema: $lema em \n$_\nNome do $nomegrupo: $$nomegrupo{$lema}\n";
		$num_casos++;
		if ($suf=~/:/) { # no caso de ser cor:original, etc.
		    $sema_final=$sema.$suf;
#		    s/$/\t0/;
		    $grupo_final=0;
		} elsif (/\_prop\t/) { # tratar dos adjectivos próprios 
#		    s/$sema$/$sema:original\t0/;
		    $sema_final="$sema:original";
		    $grupo_final=0;
		}  elsif ($grupo_mwe{$sema} eq "Original" ) {
#		    print STDERR "$lema, grupo_mwe\n";
#		    s/$sema$/$sema\t$grupo_mwe/;
		    $sema_final=$sema.":original";
		    $grupo_final=0;
		    $grupo_mwe{$sema}="";
		}  elsif ($grupo_mwe{$sema} eq "Humana" ) {
#		    print STDERR "$lema, grupo_mwe\n";
#		    s/$sema$/$sema\t$grupo_mwe/;
		    $sema_final=$sema.":humana";
		    $grupo_final=0;
		    $grupo_mwe{$sema}="";
		}  elsif ($grupo_mwe{$sema} eq "Raça" ) {
#		    print STDERR "$lema, grupo_mwe\n";
#		    s/$sema$/$sema\t$grupo_mwe/;
		    $sema_final=$sema.":raça";
		    $grupo_final=0;
		    $grupo_mwe{$sema}="";
		}  elsif ($grupo_mwe{$sema}) {
		    $sema_final=$sema;
		    $grupo_final=$grupo_mwe{$sema};
		    $grupo_mwe{$sema}="";
		}  elsif (exists $$nomegrupo{$lema}) {
#		    print "Existe... lema: $$nomegrupo{$lema}\n";
		    if ($$nomegrupo{$lema}=~/Humana/ and $sema eq "cor") {
			$sema_final="cor:humana";
			$grupo_final=0;
			print ERROS " -- Pele: $_\n";
		    } elsif ($$nomegrupo{$lema}=~/Original/ and $sema=~/cor/) {
			$sema_final="cor:original";
			$grupo_final=0;
		    } elsif ($$nomegrupo{$lema}=~/Ausência/ and $sema=~/cor/) {
			$sema_final="cor:ausência";
			$grupo_final=0;
		    } elsif ($$nomegrupo{$lema}=~/^Raça$/ and $sema=~/cor/) {
# a razão é que não quero que fique cor:raça se é Amarelo_Raça...
# mas isto tem de se resolver em geral
			$sema_final="cor:raça";
			$grupo_final=0;
		    } elsif ($$nomegrupo{$lema}=~/Vinho/ and $sema=~/cor/) {
			$sema_final="cor:vinho";
			$grupo_final=0;
		    } elsif ($$nomegrupo{$lema}=~/Equipa/ and $sema=~/cor/) {
			$sema_final="cor:equipa";
			$grupo_final=0;
		    } elsif ($$nomegrupo{$lema}=~/Outras/) {
			$sema_final=$sema;
			$grupo_final=$$nomegrupo{$lema};
			$grupo_final=~s/Outras/Outras$plural{$sema}\:$lema/;
			print ERROS " -- Outros: $_\t$$nomegrupo{$lema}:$lema\n";
		    } else {

			$sema_final=$sema;
			$grupo_final=$$nomegrupo{$lema};

			if ($alts) {
			    $grupo_final.="_0";
			}
		    } 
#		    print STDERR "Estou aqui em $lema\n";	
#		    s/\t$sema(:.*?)*\s*$/\t$sema_final/;
		} else { #havia sema na linha mas não havia valor de grupo
		    print ERROS "Atenção! $sema sem grupo, $lema: $_\n";
		    print STDERR "$_\tNaoespecificada\n";
#		    s/$/\tNaoespecificada/;
		    $sema_final=$sema;
		    $grupo_final="Naoespecificada";
		}
#		print STDERR "Estou aqui com $sema_final e $grupo_final e com $_\n";
#		s/^(?:[^\t]*?\t){$tamanho}(?:.+?)\t.*\t)$sema(:.*?)*\s*$/$1$sema_final/;
		s/\t$sema(:.*?)*\s*$/\t$sema_final/;

	    } else {	 # no caso de não pertencer ao campo semântico


	    }

	}

    } # fim dos campos semânticos
 
    print "$_\t$grupo_final\n";


}
close(ERROS);
print STDERR "Num de casos alterados: $num_casos\n";

