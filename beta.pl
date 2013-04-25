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
		default {-1;}
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
#		 # + * ( )
		[3,1,1,1,0], # #
		[2,1,1,1,2], # +
		[2,1,2,1,2], # *
		[0,1,1,1,3], # (
		[0,0,0,0,0]  # )
	);
	
	$matr[$_[0]][$_[1]];
}

sub lexicalAnalize{
	my @oprStack;
	my @opdStack;
	my $source = pop @_;
	my $pass = 0;

	push @oprStack,{token => '#'};
	while ($source) {
		if ($source =~ s/^(\d+)//){
			push @opdStack, $1;
			$pass = 1;
		}

		if ($source =~ s/^(\+)//){
			push @oprStack, { token => 'plus'};
			$pass = 1;
		}	

		if ($source =~ s/^(\*)//){
			push @oprStack, { token => 'mul'};
			$pass = 1;
		}

		if ($source =~ s/^(\()//){
			push @oprStack, { token => 'lbr' };
			$pass = 1;
		}

		if ($source =~ s/^(\))//){
			push @oprStack, { token => 'rbr',};
			$pass = 1;
		}

		if ($pass) {
			$pass = 0;
		} else {
			say 'Syntax error';
			last;
		}
	}
	push @oprStack,{token => '#'};
	(\@oprStack,\@opdStack);
}

my $oprStack; my $opdStack;
($oprStack,$opdStack) = &lexicalAnalize('1+3*39+(50*1)');

my $prev = undef;
for my $ptr (@$oprStack){
	print &relDecor(&precedMatrix(&token2int($prev)-1, &token2int($ptr->{token})-1))." " if ($prev);
	print $ptr->{token}." "; 
	$prev = $ptr->{token};
}

