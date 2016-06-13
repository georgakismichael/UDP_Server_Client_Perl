use strict;
use warnings;
use IO::Socket;
use String::CRC32;
use Getopt::Long;

my($result, $udp_client_socket, $DESTIP, $PORTNO, $PROTO, $MAXSZ, $killserver, $load, $outgoing, $ServerRunning, $ack, $ack_str, $checksum);

$result = GetOptions (	
	"host:s"   	=> \$DESTIP,
	"port:i" 	=> \$PORTNO,
	"load:i" 	=> \$load,
	"size:i" 	=> \$MAXSZ,
	"killserver:s" 	=> \$killserver,	
);

if(!($DESTIP))
{
	$DESTIP = '127.0.0.1';
	print "Target IP argument missing. Assuming $DESTIP...\n";
}

if(!($PORTNO))
{
	$PORTNO = 5152;
	print "Target Port argument missing. Assuming $PORTNO...\n";

}

if(!($load))
{
	$load = 100;
	print "Number of messages argument missing. Assuming $load...\n";
}

if(!($MAXSZ))
{
	$MAXSZ = 1024;
	print "Message size argument missing. Assuming $MAXSZ bytes...\n";
}

if(($killserver ne "YES") and ($killserver ne "NO"))
{
	$killserver = 1;
	print "Server shutdown argument missing or invalid. Assuming YES...\n";
}

$PROTO = 'udp';

print "Starting $PROTO client on port $PORTNO\n";

$udp_client_socket = new IO::Socket::INET(PeerAddr => $DESTIP, PeerPort => $PORTNO, Proto => $PROTO)
or die "Couldn't create a $PROTO client on port $PORTNO : $@\n";

print "Ready to sent $PROTO messages to $DESTIP port $PORTNO\n";

$ServerRunning = 0;

while(!$ServerRunning)
{
	$outgoing = "hello";
	$udp_client_socket->send($outgoing);
	
	if($udp_client_socket->recv($ack, $MAXSZ))
	{
		my($ack_str, $checksum) = split(/_/, $ack);
		
		if(($ack_str eq "ACK") and ($checksum == crc32($outgoing)))
		{
			print ("Server is alive!\n");
			$ServerRunning = 1;
		}
		else
		{
			die ("Server handshake did not complete successfully. Exiting...\n");
		}	
	}
	else
	{
		print ("Waiting for server...\n");
		sleep(2);
	}	
}

my($pkts_fail, $pkts_ok, $stats) =(0, 0);

for($a=0;$a<$load; $a+=1)
{
	$outgoing = join'', map +(0..9,'a'..'z','A'..'Z')[rand(10+26*2)], 1..$MAXSZ;

	$udp_client_socket->send($outgoing);
	$udp_client_socket->recv($ack, $MAXSZ);
	
	my($ack_str, $checksum) = split(/_/, $ack);
	
	if(($ack_str ne "ACK") or ($checksum != crc32($outgoing)))
	{
		$pkts_fail+=1;
	}
	else
	{
		$pkts_ok+=1;
	}	
}

$stats = ($pkts_ok/($pkts_ok + $pkts_fail))*100;

print "$pkts_fail packets failed and $pkts_ok packets were transmitted properly ($stats%)\n";

if($killserver eq "YES")
{
	$outgoing = "killmenow";

	$udp_client_socket->send($outgoing);
	$udp_client_socket->recv($ack, $MAXSZ);

	sleep(2);
}

$udp_client_socket -> close();