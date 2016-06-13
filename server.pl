use strict;
use warnings;
use IO::Socket;

my($udp_server_socket, $PORTNO, $PROTO, $incoming, $from_address, $from_port);

$PORTNO = 5151;
$PROTO = 'udp';

print "Starting $PROTO server on port $PORTNO... ";

$udp_server_socket = new IO::Socket::INET(LocalHost => '127.0.0.1', LocalPort => $PORTNO, Proto => $PROTO)
or die "Couldn't create a $PROTO server on port $PORTNO : $@\n";

print "OK\n";

print "Awaiting $PROTO messages on port $PORTNO\n";

while(1)
{
	# read operation on the socket
	$udp_server_socket->recv($incoming, 1024);

	#get the peerhost and peerport at which the recent data received.
	$from_address = $udp_server_socket->peerhost();
	$from_port = $udp_server_socket->peerport();
	print "\n($from_address , $from_port) said : $incoming";
}