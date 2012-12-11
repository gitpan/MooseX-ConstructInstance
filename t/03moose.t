=head1 PURPOSE

Test that MooseX::ConstructInstance works with Moose.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use strict;
use warnings;
use Test::More;
use if ($] < 5.010), 'UNIVERSAL::DOES';

BEGIN {
	eval q{ require Moose; 1 } or plan skip_all => 'requires Moose';
}

{
	package Local::Other;
	use Moose;
	has param => (is => 'rw');
}

{
	package Local::Class1;
	use Moose;
	with qw( MooseX::ConstructInstance );
	has xxx => (is => 'ro');
	sub make_other {
		my $self = shift;
		$self->construct_instance('Local::Other', param => $self->xxx);
	}
}

{
	package Local::Class2;
	use Moose;
	extends qw( Local::Class1 );
	around make_other => sub {
		my ($orig, $self, $class, @args) = @_;
		my $inst = $self->$orig($class, @args);
		$inst->param(2) if $inst->DOES('Local::Other');
		return $inst;
	}
}

can_ok 'Local::Class1', 'construct_instance';
ok !Local::Class1->can('import');

{
	my $obj = Local::Class1->new(xxx => 3);
	my $oth = $obj->make_other;
	is($oth->param, 3);
}

{
	my $obj = Local::Class2->new(xxx => 3);
	my $oth = $obj->make_other;
	is($oth->param, 2);
}

done_testing;