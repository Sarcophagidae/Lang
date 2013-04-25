#!/usr/bin/perl -w
use strict;
use 5.014;

sub token2int{
	my $token = pop @_;
	given ($token) {
		when (/\#/) {1;}
		when (/plus/) {2;}
		when (/mul/) {3;}
		when (/lbr/) {4;}
		when (/rbr/) {5;}
		when (/sub/) {6;}
		when (/div/) {7;}

		default {-1;}
	}
}

sub int2token{
	my $token = pop @_;
	given ($token) {
		when (1){'#'}
		when (2){'plus';}
		when (3){'mul';}
		when (4){'lbr';}
		when (5){'rbr';}
		when (6){'sub';}
		when (7){'div';}

		default {'';}
	}
}

sub relDecor{
	given ($_[0]){
		when (/1/){'<'};
		when (/2/){'>'};
		when (/3/){'='};
		when (/0/){'XXX'};
	}
}

sub precedMatrix{
# < - 1 
# > - 2
# = - 3
# none = 0
	my @matr = (
#		 # + * ( ) - /
		[1,1,1,1,0,1,1], # #
		[2,2,1,1,2,2,1], # +
		[2,2,2,1,2,2,1], # *
		[0,1,1,1,3,1,1], # (
		[2,2,2,0,2,2,2], # )
		[2,2,1,1,2,2,1], # -
		[2,2,2,1,2,2,1], # /
	);

	if (($_[0] <= 0) || ($_[1] <=0)){
		-1; }
	else {
		$matr[$_[0]-1][$_[1]-1];
	}
	
}

sub printStacks{
	say "";
	my ($opr, $opd) = ($_[0], $_[1]);
	my $max = (@$opr > @$opd)?@$opr:@$opd;
	say "Oper\t|\tOpd";
	say "-"x19;
	
		
	for my $i(0..scalar @$opr-1){
		if (${$opr}[$i]{token}){
			print ${$opr}[$i]{token};
		}
		print "\t|\t";
		if ($$opd[$i]){
			print $$opd[$i];
		}
		print "\n";
	}
	say "-"x19;
}

sub printOprStack{
	my ($opr) = ($_[0]);
	my $stackSize = @$opr;
	
	my $prev = $$opr[0]->{token};	
	print $prev;

	for (my $i = 1; $i < $stackSize; $i++) {
		print " ".&relDecor(&precedMatrix(&token2int($prev),&token2int($$opr[$i]->{token})));

		print " ".$$opr[$i]->{token};
		$prev = $$opr[$i]->{token};	
	}
	print "\n";

}

sub relWithLast{
	my $stack = $_[0]; 
	my $token = $_[1];
	&precedMatrix(&token2int(@$stack[-1]->{token}),&token2int($token));
}

sub semAriphmetic{
	my $opr = $_[0];
	my $opd = $_[1];
	my $index = $_[2];
	my $rValue = pop @$opd;
	my $lValue = pop @$opd;	
	
	if ((defined($rValue))&&(defined($lValue))){
		given ($$opr[$index]->{token}){
			when (/plus/) {
 				push @$opd, $lValue + $rValue;
			}
			when (/mul/){
				push @$opd, $lValue * $rValue;
			}
			when (/sub/){
				push @$opd, $lValue - $rValue;
			}
			when (/div/){
				if ($rValue == 0){
					say "rror: Illegal division by zero";
					exit;
				}
				push @$opd, $lValue / $rValue;
			}
			
		}	
		splice (@$opr, $index, 1);
		1;
	}	
		else {
		-1;
	}
}

sub semLbrRbr{
	my $opr = $_[0];
	my $opd = $_[1];
	my $lIndex = $_[2];
	my $rIndex = $_[3];
	
	if (@$opd>0){
		splice (@$opr, $lIndex, $rIndex-$lIndex+1);
		1;
	}	
		else {	
		-1;
	}
}



sub backTrace2{
	my ($opr, $opd) = ($_[0], $_[1]);
	my $repeatAgain = 1;

AGAIN:	
	my $stackSize = @$opr;
	my $lastRuleToken = -1;;	
	my $firstRuleToken = -1;
	my @rule = ();

	for (my $i = $stackSize - 2; $i >= 0; $i --) {
		my $rel = &precedMatrix(&token2int($$opr[$i]->{token}), &token2int($$opr[$i+1]->{token}));
		$lastRuleToken = $i if ($rel == 2);
		if ($rel == 0){
			say "Syntax error: unexpected place of smth";	
			exit;
		}
 
		if ($rel == -1){
			say "Syntax error: WHA A Y DOIN? Write mail 2 author with param of syntaxAnalize";
			exit;
		}
	
	}
		
	if ($lastRuleToken > 0){
		for (my $i = $lastRuleToken-1; $i >=0; $i --){
			my $rel = &precedMatrix(&token2int($$opr[$i]->{token}), &token2int($$opr[$i+1]->{token}));
			unshift @rule, $$opr[$i+1]->{token};
			if ($rel == 1) {
				$firstRuleToken = $i + 1;
				last;
			}
		}
	};

	if (($lastRuleToken == -1)&&($stackSize == 2)) {
		if (($$opr[0]->{token} eq '#') and ($$opr[1]->{token} eq '#')){
			unshift @rule, '#';
			unshift @rule, '#';
		}
	}

	my $rule = join ' ',@rule;
	given ($rule){
		when (/(plus)|(mul)|(sub)|(div)/){ 
			if (&semAriphmetic($opr, $opd, $firstRuleToken)<0){	
				say "Syntax error: Operand expected";	
				exit;
			}
		};

		when (/lbr rbr/){
			if (&semLbrRbr($opr, $opd, $firstRuleToken,$lastRuleToken)<0){
				say "Syntax error: Empty bracket";
				exit;
			}
		};
	
		when (/\# \#/){
			if (@$opd !=1) {
				say "Syntax error: Stack is dead. You are cheater.";
				exit;	
			}
			$repeatAgain = 0;
		}
		
		when (/.*XXX.*/){
			
		}

		default {
				$repeatAgain = 0;
		}
	}
	goto AGAIN if ($repeatAgain);
	
	$rule;
}


sub getNextToken{
	$_[0]=~s/^\s+//;
	return '#' unless $_[0]; 
	
	return ('int',$1)  if ($_[0] =~ s/^(\-?\d+)//);
	return 'plus' if ($_[0] =~ s/^(\+)//);
	return 'mul'  if ($_[0] =~ s/^(\*)//);
	return 'lbr'  if ($_[0] =~ s/^(\()//);
	return 'rbr'  if ($_[0] =~ s/^(\))//);
	return 'sub'  if ($_[0] =~ s/^(\-)//);
	return 'div'  if ($_[0] =~ s/^(\/)//);
	
	
	return 'err';
}

sub syntaxAnalize{
	my $source = pop @_;
	my $parsing = 1;
	my (@oprStack, @opdStack); 

	say $source;

	push @oprStack,{token => '#'};
	my $iterCount = 0;
	while ($parsing) {
		my ($curToken, $value) = &getNextToken($source);
		given ($curToken){
			when (/int/) {	
				push @opdStack, $value;
			}

			when (/err/){
				say 'Syntax error: Undefined indentificator';
				exit;	
			}

			when (/#/){
				push @oprStack, {token => '#'};
				$parsing = 0;
			}	
			
			default {
				push @oprStack, {token => $curToken};
			}
		}
		&printOprStack(\@oprStack) if $curToken ne 'int';
		&backTrace2(\@oprStack,\@opdStack) if $curToken ne 'int';

	}

#	say "Parsing finish"; 
	&printStacks(\@oprStack,\@opdStack);
	(\@oprStack,\@opdStack);
}

#say &precedMatrix(&token2int('plus'),&token2int('plus'));
unless (defined $ARGV[0]) {
	say "Parser v6. \n Usage: lang.pl <expression>";
} else {
	&syntaxAnalize($ARGV[0]);
}


