use strict;
use warnings;
use IO::Socket;
use String::CRC32;
use Getopt::Long;

my($result, $udp_server_socket, $PORTNO, $PROTO, $MAXSZ, $incoming, $from_address, $from_port, $ServerRunning, $ack, $crc, $unixtime, $directory);

$result = GetOptions (	
	"port:i" 	=> \$PORTNO,
	"size:i" 	=> \$MAXSZ,
	"directory:s" 	=> \$directory,
);

if(!($PORTNO))
{
	$PORTNO = 5152;
	print "Target Port argument missing. Assuming $PORTNO...\n";

}

if(!($MAXSZ))
{
	$MAXSZ = 1024;
	print "Message size argument missing. Assuming $MAXSZ bytes...\n";
}

if(!($directory))
{
	$directory = "logs";
	print "Directory argument missing. Assuming $directory ...\n";
}

$PROTO = 'udp';

$directory = $directory."//";

if(!(-d $directory))
{
	print "$directory does not exist. Creating it...\n";
	
	unless(mkdir $directory)
	{
		die "Unable to create $directory. Exiting...\n";
	}
}
else
{
	print "$directory exists\n";
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
	
	if($incoming eq "killmenow")
	{
		print "\nServer kill message recieved from $from_address. Stopping server...\n";
		$ServerRunning = 0;
	}	
	elsif($incoming eq "hello")
	{
		print "Handshake request received.\n"
	}
	else
	{
		my $filename = $directory.$unixtime."_".$crc;
		open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
		print $fh "$incoming\n";
		close $fh;	
	}
}

$udp_server_socket -> close;