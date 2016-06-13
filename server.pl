use strict;
use warnings;
use IO::Socket;

my($udp_server_socket, $PORTNO, $PROTO);

$PORTNO = 5151;
$PROTO = 'udp';

print "Starting $PROTO on port $PORTNO\n";

$udp_server_socket = IO::Socket::INET->new(LocalPort => $PORTNO, Proto => $PROTO)
or die "Couldn't create a $PROTO server on port $PORTNO : $@\n";

print "Awaiting $PROTO messages on port $PORTNO\n";