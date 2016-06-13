use strict;
use warnings;
use IO::Socket;

my($udp_client_socket, $DESTIP, $PORTNO, $PROTO, $MAXSZ, $outgoing, $ServerRunning, $ack);

$PORTNO = 5152;
$PROTO = 'udp';
$DESTIP = '127.0.0.1';
$MAXSZ = 1024;

print "Starting $PROTO client on port $PORTNO\n";

$udp_client_socket = new IO::Socket::INET(PeerAddr => $DESTIP, PeerPort => $PORTNO, Proto => $PROTO)
or die "Couldn't create a $PROTO client on port $PORTNO : $@\n";

print "Ready to sent $PROTO messages to port $PORTNO\n";

$ServerRunning = 0;

while(!$ServerRunning)
{
	$outgoing = "hello";
	$udp_client_socket->send($outgoing);
	$udp_client_socket->recv($ack, $MAXSZ);

	if($ack eq "ACK")
	{
		print ("Server is alive!\n");
		$ServerRunning = 1;
	}
	else
	{
		print ("Waiting for server...\n");
		sleep(2);
	}	
}

for( $a = 1; $a < 200; $a = $a + 1 )
{
	$outgoing = join'', map +(0..9,'a'..'z','A'..'Z')[rand(10+26*2)], 1..8;

	$udp_client_socket->send($outgoing);
	$udp_client_socket->recv($ack, $MAXSZ);
	
	if($ack ne "ACK")
	{
		die "No ACK!!!";
	}		
}

$outgoing = "killmenow";

$udp_client_socket->send($outgoing);
$udp_client_socket->recv($ack, $MAXSZ);
print "Data received from socket : $ack\n";

sleep(2);

$udp_client_socket -> close();