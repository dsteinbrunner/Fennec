package Test::Workflow::Meta;
use strict;
use warnings;

use Test::Workflow::Layer;
use Test::Builder;

use Fennec::Util qw/accessors/;

accessors qw{
    test_class build_complete root_layer test_run test_sort
    ok diag skip todo_start todo_end debug_long_running
};

sub new {
    my $class = shift;
    my ($test_class) = @_;

    my $tb = "tb";

    my $self = bless(
        {
            test_class => $test_class,
            root_layer => Test::Workflow::Layer->new(),
            ok         => Fennec::Util->can("${tb}_ok"),
            diag       => Fennec::Util->can("${tb}_diag"),
            skip       => Fennec::Util->can("${tb}_skip"),
            todo_start => Fennec::Util->can("${tb}_todo_start"),
            todo_end   => Fennec::Util->can("${tb}_todo_end"),
        },
        $class
    );

    return $self;
}

1;

__END__

=head1 NAME

Test::Workflow::Meta - The meta-object added to all Test-Workflow test classes.

=head1 DESCRIPTION

When you C<use Test::Workflow;> a function is added to you class named
'TEST_WORKFLOW' that returns the single Test-Workflow meta-object that tracks
information about your class.

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2011 Chad Granum

Test-Workflow is free software; Standard perl licence.

Test-Workflow is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.
