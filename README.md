# UDP_Server_Client_Perl
This repository will host a UDP client/server application written in Perl.

Usage for server:

<perl binaries path> server.pl -port -size -directory
-port: The server port to listen for connections (Default 5152).
-size: The message size to expect in bytes. Make sure that the clients message size does not exceed this number (Default 1024).
-directory: The name of the directory where the files with the messages will be saved. If that directory does not exist it will be created (Default logs/).

Usage for client:

<perl binaries path> client.pl -host -port -size -load -killserver
-host: The server IP the client will attempt to connect to (Default 127.0.0.1).
-port: The server port the client will attempt to connect to (Default 5152).
-size: The message size to expect in bytes. Make sure that the server's message size is greater or equal to this number (Default 1024).
-load: The number of messages the client will send to the server. The size of the messages is defined via the -size argument (Default 100).
-killserver: If set to YES the client will send a kill command to the server after it has finished sending messages (Default YES).

Log File names

The log files contain in text the messages that the client sent to the server. The naming convention they follow is: 

<unixtime of the time the message was received>_<CRC32 value of the message in decimal>

Tested on Windows 10 using perl 5, version 14, subversion 2 (v5.14.2) built for MSWin32-x86-multi-thread.
Tested on Linux 4.2.0-16-generic #19-Ubuntu SMP Thu Oct 8 15:35:06 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux using perl 5, version 20, subversion 2 (v5.20.2) built for x86_64-linux-gnu-thread-multi.

Prerequisites

Windows: None
Linux: String::CRC32 To install it toggle perl shell with:
perl -e shell -MCPAN
and install the package with:
install String::CRC32
