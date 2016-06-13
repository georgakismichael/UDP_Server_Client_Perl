use strict;
use warnings;
use IO::Socket;
use String::CRC32;

my($udp_client_socket, $DESTIP, $PORTNO, $PROTO, $MAXSZ, $outgoing, $ServerRunning, $ack, $ack_str, $checksum);

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
	
	my($ack_str, $checksum) = split(/_/, $ack);
	
	if(($ack_str eq "ACK") and ($checksum == crc32($outgoing)))
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

my($pkts_fail, $pkts_ok, $stats) =(0, 0);

for($a=0;$a<10; $a+=1)
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

$outgoing = "killmenow";

$udp_client_socket->send($outgoing);
$udp_client_socket->recv($ack, $MAXSZ);

sleep(2);

$udp_client_socket -> close();