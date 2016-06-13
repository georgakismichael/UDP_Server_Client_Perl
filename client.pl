use strict;
use warnings;
use IO::Socket;

my($udp_client_socket, $PORTNO, $PROTO);

$PORTNO = 5151;
$PROTO = 'udp';

print "Starting $PROTO client on port $PORTNO\n";

$udp_client_socket = new IO::Socket::INET(PeerAddr => '127.0.0.1', PeerPort => $PORTNO, Proto => $PROTO)
or die "Couldn't create a $PROTO client on port $PORTNO : $@\n";

print "Ready to sent $PROTO messages to port $PORTNO\n";
