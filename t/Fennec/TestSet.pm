package TEST::Fennec::TestSet;
use strict;
use warnings;

use Fennec;
my $CLASS = 'Fennec::TestSet';
use_ok( $CLASS );

tests 'warn for unobserved' => sub {
    my $line;
    my ( $warn ) = capture_warnings {
        do {
            my $set = $CLASS->new( 'xxx', file => 'file', line => '1', method => sub { 1 });
            $set = undef
        };
    };
    my @parts = split('\n', $warn );
    my $total = @parts;

    is(
        shift( @parts ),
        "Testset was never observed by the runner:",
        "Warning Part " . ($total - @parts )
    );
    is( shift( @parts ), "\tName: xxx", "Warning Part " . ($total - @parts ));
    is( shift( @parts ), "\tFile: file", "Warning Part " . ($total - @parts ));
    is( shift( @parts ), "\tLine: 1", "Warning Part " . ($total - @parts ));
    is( shift( @parts ), "", "Warning Part " . ($total - @parts ));
    is(
        shift( @parts ),
        "This is usually due to nesting a workflow within another workflow that does not",
        "Warning Part " . ($total - @parts )
    );
    is( shift( @parts ), "support nesting.", "Warning Part " . ($total - @parts ));
    is( shift( @parts ), "", "Warning Part " . ($total - @parts ));
    is( shift( @parts ), "Workflow stack:", "Warning Part " . ($total - @parts ));
    is( shift( @parts ), "No Workflow", "Warning Part " . ($total - @parts ));
};

1;
