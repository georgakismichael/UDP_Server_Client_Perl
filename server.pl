use strict;
use warnings;
use IO::Socket;

my($udp_server_socket, $PORTNO, $PROTO, $MAXSZ, $incoming, $from_address, $from_port, $ServerRunning, $ack);

$PORTNO = 5151;
$PROTO = 'udp';
$MAXSZ = 1024;

print "Starting $PROTO server on port $PORTNO... ";

$udp_server_socket = new IO::Socket::INET(LocalHost => '127.0.0.1', LocalPort => $PORTNO, Proto => $PROTO)
or die "Couldn't create a $PROTO server on port $PORTNO : $@\n";

print "OK\n";

print "Awaiting $PROTO messages on port $PORTNO\n";

$ServerRunning = 1;

while($ServerRunning)
{
	# read operation on the socket
	$udp_server_socket->recv($incoming, $MAXSZ);

	#get the peerhost and peerport at which the recent data received.
	$from_address = $udp_server_socket->peerhost();
	$from_port = $udp_server_socket->peerport();
	print "\n($from_address , $from_port) said : $incoming\n";

	$ack = "ACK";
	$udp_server_socket->send($ack);
	print "Sent $ack to $from_address:$from_port\n";
	
	if($incoming eq "killmenow")
	{
		print ("\nServer kill message recieved from $from_address. Stopping server...\n");
		$ServerRunning = 0;
	}	
}

$udp_server_socket -> close;