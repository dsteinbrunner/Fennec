package Fennec::Tester::Listener;
use strict;
use warnings;

use IO::Socket::UNIX;
use File::Temp qw/tempfile/;
use Fennec::Tester::Root;
use Fennec::Util qw/add_accessors/;
use Carp;

add_accessors qw/socket file connections/;

sub new {
    my $class = shift;
    my ( $fh, $socket_file ) = tempfile( cwd() . "/.test-suite.$$.XXXX"  );
    close( $fh ) || die( $! );
    unlink( $socket_file );
    my $socket = IO::Socket::UNIX->new(
        Listen => 1,
        Local => $socket_file,
    ) || die( $! );
    return bless({ socket => $socket, file => $file, connections => [] }, $class);
}

sub interation {
    my $self = shift;
    $self->accept_connections;
    $self->read;
}

sub accept_connections {
    my $self = shift;
    # Get new connections
    my $socket = $self->socket;
    $socket->blocking( 0 );
    while( my $incoming = $socket->accept ) {
        push @{ $self->connections } => $incomming;
    }
}

sub read {
    # Get results/diag from all connections.
    for my $child ( @{ $self->connections }) {
        $child->blocking( 0 );
        $child->autoflush( 1 );
        eval { print $child "ping\n" };
        unless ( $child->connected ) {
            $self->connections([
                grep { $_ != $child } @{ $self->connections }
            ]);
            next;
        }
        while ( my $msg = <$child> ) {
            $self->process( $msg );
        }
    }
}

sub finish {
    my $self = shift;
    while ( @{ $self->connections }) {
        $self->iteration;
        sleep 1;
    }
}

sub process {
    my $self = shift;
    my ( $msg ) = @_;
    my $item = eval $msg;
    return Fennec::Tester->get->direct_diag( $msg )
        unless ref( $msg );
    return Fennec::Tester->get->direct_result( $msg )
        if ( $item->isa( 'Fennec::Result' ));
    croak( "Unhandled message $msg" );
}

sub DESTROY {
    my $self = shift;
    # Close sockets and unlink file.
    for my $child ( @{ $self->connections }) {
        close( $child );
    }
    my $socket = $self->socket;
    close( $socket );
    unlink( $self->file );
}

1;
