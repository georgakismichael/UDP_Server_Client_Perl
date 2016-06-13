use strict;
use warnings;
use IO::Socket;
use String::CRC32;

my($udp_server_socket, $PORTNO, $PROTO, $MAXSZ, $incoming, $from_address, $from_port, $ServerRunning, $ack, $crc, $unixtime, $directory);

$PORTNO = 5152;
$PROTO = 'udp';
$MAXSZ = 1024;
$directory = "logs\\";

if(!(-d $directory))
{
	print "$directory does not exist. Creating it...\n";
	
	unless(mkdir $directory)
	{
		die "Unable to create $directory. Exiting...\n";
	}
}

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
	
	if(!($from_address or $from_port))
	{
		die "Bad packet size. Exiting...\n";
	}
	
	$crc = crc32($incoming);
	$unixtime = time;
	print "\n$unixtime : ($from_address , $from_port) said : $incoming ($crc)\n";
	$ack = "ACK_".$crc;
	$udp_server_socket->send($ack);
	print "Sent $ack to $from_address:$from_port\n";	
	
	my $filename = $directory.$unixtime."_".$crc;
	open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
	print $fh "$incoming\n";
	close $fh;
	
	if($incoming eq "killmenow")
	{
		print ("\nServer kill message recieved from $from_address. Stopping server...\n");
		$ServerRunning = 0;
	}	
}

$udp_server_socket -> close;