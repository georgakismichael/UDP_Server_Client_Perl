use strict;
use warnings;
use IO::Socket;

my($udp_client_socket, $DESTIP, $PORTNO, $PROTO, $outgoing, $ack);

$PORTNO = 5151;
$PROTO = 'udp';
$DESTIP = '127.0.0.1';

print "Starting $PROTO client on port $PORTNO\n";

$udp_client_socket = new IO::Socket::INET(PeerAddr => $DESTIP, PeerPort => $PORTNO, Proto => $PROTO)
or die "Couldn't create a $PROTO client on port $PORTNO : $@\n";

print "Ready to sent $PROTO messages to port $PORTNO\n";

$outgoing = "asdasadasd";
$udp_client_socket->send($outgoing);

#read operation
$ack = <$udp_client_socket>;
print "Data received from socket : $ack\n ";

sleep(10);
$udp_client_socket->close();