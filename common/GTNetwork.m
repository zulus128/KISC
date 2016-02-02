//
//  GTNetwork.m
//
//  Created by renat.karimov on 2/13/13.
//  Copyright (c) 2013 Gamma Technologies Research Laboratory LLP. All rights reserved.
//

#import "GTNetwork.h"

@interface GTNetwork() {
    unsigned char *_response;
    long _responseSize;
}

@end

@implementation GTNetwork

- (id)init {
    if ((self = [super init])) {
        _response = NULL;
        _responseSize = 0;
    }
    return self;
}

- (void)dealloc
{
    if (_response != NULL) {
        SAFEFREE(_response);
    }
    [super dealloc];
}

- (int)createSocketDescriptorAndConnectToHost:(NSString *)host withPort:(int)port
{
    int socketDescriptor = 0;
    int serverId = 0;
    struct sockaddr_in serverSocketAddress;
    struct hostent *hostInformation = NULL;
    socketDescriptor = socket(AF_INET, SOCK_STREAM, 0);
    if (socketDescriptor < 0) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:socketDescriptor], @"socketDescriptor", [NSNumber numberWithInt:errno], @"errno", nil];
        @throw [NSException exceptionWithName:@"GTNetworkException" reason:@"Cannot create socket descriptor" userInfo:dictionary];
    }
    hostInformation = gethostbyname([host UTF8String]);
    if (hostInformation == NULL) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:host, @"host", [NSNumber numberWithInt:h_errno], @"h_errno", nil];
        @throw [NSException exceptionWithName:@"GTNetworkException" reason:@"Cannot get host by name" userInfo:dictionary];
    }
    bzero((char *) &serverSocketAddress, sizeof(serverSocketAddress));
    serverSocketAddress.sin_family = AF_INET;
    bcopy((char *)hostInformation->h_addr, (char *)&serverSocketAddress.sin_addr.s_addr, hostInformation->h_length);
    serverSocketAddress.sin_port = htons(port);
    serverId = connect(socketDescriptor, (struct sockaddr *)&serverSocketAddress, sizeof(serverSocketAddress)); 
    if (serverId < 0) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:serverId], @"serverId", [NSNumber numberWithInt:errno], @"errno", host, @"host", [NSNumber numberWithInt:port], @"port", nil];
        @throw [NSException exceptionWithName:@"GTNetworkException" reason:@"Cannot connect to host" userInfo:dictionary];
    }
    return socketDescriptor;
}

- (void)closeSocketDescriptor:(int)socketDescriptor
{
    close(socketDescriptor);
}

- (long)sendRequest:(unsigned char *)request withSize:(long)size andHeaderSize:(int)headerSize usingSocketDescriptor:(int)socketDescriptor
{
    long transmittedBytesCount = 0;
    long tempLength = 0;
    unsigned char header[8];
    unsigned char *finalRequest = NULL;
    if (headerSize != 5 && headerSize != 7) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:headerSize], @"headerSize", nil];
        @throw [NSException exceptionWithName:@"GTNetworkException" reason:@"Illegal header size" userInfo:dictionary];
    }
    
    if (!request || (size < 1)) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:size], @"size", nil];
        @throw [NSException exceptionWithName:@"GTNetworkException" reason:@"Illegal request" userInfo:dictionary];
    }
    
    if (headerSize == 0) {
        if (request && size) {
            transmittedBytesCount = send(socketDescriptor, request, size, 0);
            if (transmittedBytesCount < 0) {
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:transmittedBytesCount], @"transmittedBytesCount", [NSNumber numberWithInt:errno], @"errno", nil];
                @throw [NSException exceptionWithName:@"GTNetworkException" reason:@"Cannot send request" userInfo:dictionary];
            }
            return transmittedBytesCount;
        }
    }

    tempLength = size + headerSize - 4;
    CFByteOrder byteOrder = CFByteOrderGetCurrent();
    if (byteOrder == CFByteOrderLittleEndian) {
        // INVERT
        drct_l(tempLength);
    } else if (byteOrder == CFByteOrderBigEndian) {
        // DIRECT
    } else if (byteOrder == CFByteOrderUnknown) {
        // UNKNOWN
    }
    
    memcpy(header, &tempLength, 4);
    if (headerSize == 5) {
        header[4] = 0x0;
    } else { 
        header[4] = CMP_TCP_VER;
        header[5] = 0;
        header[6] = 0x0;
    }
    
    finalRequest = (unsigned char*) calloc(size + headerSize + 1, sizeof(unsigned char));
    memcpy(finalRequest, header, headerSize);
    memcpy(finalRequest + headerSize, request, size);
    
    transmittedBytesCount = send(socketDescriptor, finalRequest, size + headerSize, 0);
    SAFEFREE(finalRequest);
    
    if (transmittedBytesCount < 0) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:transmittedBytesCount], @"transmittedBytesCount", [NSNumber numberWithInt:errno], @"errno", nil];
        @throw [NSException exceptionWithName:@"GTNetworkException" reason:@"Cannot send request" userInfo:dictionary];
    }
    return transmittedBytesCount;
}

- (long)retryReadBuffer:(unsigned char *)buffer withSize:(long)size usingSocketDescriptor:(int)socketDescriptor
{
	long readBytesCount = 0;
    long totalReadBytesCount = 0;
	unsigned char *localBuffer = buffer;
	if (size == 0) {
		return 0;
	}
	for(;;) {
		readBytesCount = recv(socketDescriptor, localBuffer, size, 0);
		if (readBytesCount == -1 || readBytesCount == 0) 
        {
			if (errno == EINTR || errno == EAGAIN) 
            {
				continue;
			}
			return -1;
		}
		totalReadBytesCount += readBytesCount;
		if (readBytesCount >= size) 
        {
			return totalReadBytesCount;
		}
		localBuffer  += readBytesCount;
		size -= readBytesCount;
	}
}

- (void)readLine:(char **)line usingSocketDescriptor:(int)socketDescriptor
{
	long readBytesCount = 0;
    unsigned char oneByte;
    NSMutableData *buffer = [NSMutableData data];
	while(true)
    {
		readBytesCount = recv(socketDescriptor, &oneByte, 1, 0);
        if (readBytesCount == -1) {
            if (errno == EINTR || errno == EAGAIN)
            {
				continue;
			}
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:readBytesCount], @"readBytesCount", [NSNumber numberWithInt:errno], @"errno", nil];
            @throw [NSException exceptionWithName:@"GTNetworkException" reason:@"Cannot read line" userInfo:dictionary];
        } else if (readBytesCount == 0) {
            continue;
        } else if (readBytesCount == 1) { 
            if (oneByte == '\0') {
                if (buffer.length > 0) {
                    [buffer appendBytes:&oneByte length:1];
                    if (_response != NULL) {
                        SAFEFREE(_response);
                    }
                    _responseSize = buffer.length;
                    _response = (unsigned char *) malloc(sizeof(unsigned char) * _responseSize);
                    memcpy(_response, buffer.bytes, buffer.length);
                    *line = (char *)_response;
                } else {
                    *line = NULL;
                }
                return;
            } else {
                [buffer appendBytes:&oneByte length:1];
            }
        }
	}
}

- (void)readBytes:(unsigned char *)bytes withSize:(long)size usingSocketDescriptor:(int)socketDescriptor
{
	long readBytesCount = 0;
	long totalReadBytesCount = 0;
    unsigned char oneByte;
    NSMutableData *buffer = [NSMutableData data];
	while(true)
    {
		readBytesCount = recv(socketDescriptor, &oneByte, 1, 0);
        if (readBytesCount == -1) {
            if (errno == EINTR || errno == EAGAIN)
            {
				continue;
			}
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:readBytesCount], @"readBytesCount", [NSNumber numberWithInt:errno], @"errno", nil];
            @throw [NSException exceptionWithName:@"GTNetworkException" reason:@"Cannot read bytes" userInfo:dictionary];
        } else if (readBytesCount == 0) {
            continue;
        } else if (readBytesCount == 1) {
            [buffer appendBytes:&oneByte length:1];
            totalReadBytesCount += readBytesCount;
            if (totalReadBytesCount == size)
            {
                if (buffer.length > 0) {
                    memcpy(bytes, buffer.bytes, buffer.length);
                } else {
                    // Ignore
                }
                return;
            }
        }
	}
}

- (void)writeBytes:(const unsigned char *)bytes withSize:(long)size usingSocketDescriptor:(int)socketDescriptor
{
    long transmittedBytesCount = 0;
        
    if (bytes != NULL) {
        transmittedBytesCount = send(socketDescriptor, bytes, size, 0);
        if (transmittedBytesCount < 0 || transmittedBytesCount != size) {
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:transmittedBytesCount], @"transmittedBytesCount", [NSNumber numberWithInt:errno], @"errno", nil];
            @throw [NSException exceptionWithName:@"GTNetworkException" reason:@"Cannot write bytes" userInfo:dictionary];
        }
    }
}

- (void)receiveResponse:(unsigned char **)response withSize:(long *)size usingSocketDescriptor:(int)socketDescriptor
{
    long readBytesCount = 0;
    int headerSize = 0;
    unsigned char header[8];
	    
    readBytesCount = [self retryReadBuffer:header withSize:HEADER_SIZE_5 usingSocketDescriptor:socketDescriptor];
    if (readBytesCount != 5) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:readBytesCount], @"readBytesCount", nil];
        @throw [NSException exceptionWithName:@"GTNetworkException" reason:@"Cannot receive response" userInfo:dictionary];
    }
	
    if (header[0] != 0) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedChar:header[0]], @"header_0", nil];
        @throw [NSException exceptionWithName:@"GTNetworkException" reason:@"Bad response received" userInfo:dictionary];
    }
	
    if (header[4] < 7) {
        headerSize = 5;
    } 
    else if (header[4] == CMP_TCP_VER) {
        readBytesCount = [self retryReadBuffer:header + 5 withSize:DIFF_BETWEEN_HEADER_SIZES usingSocketDescriptor:socketDescriptor];
        if (readBytesCount != 2) {
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:readBytesCount], @"readBytesCount", nil];
            @throw [NSException exceptionWithName:@"GTNetworkException" reason:@"Cannot receive response" userInfo:dictionary];
        }
        headerSize = 7;
    } 
    else {
        @throw [NSException exceptionWithName:@"GTNetworkException" reason:@"Bad response received" userInfo:nil];
    }
    _responseSize = 0x10000 * ((int)header[1]) + 0x100 * ((int)header[2]) + ((int)header[3]) - (headerSize - 4);
    if (_response != NULL) {
        SAFEFREE(_response);
    }
    _response = (unsigned char *) calloc(_responseSize + 1, sizeof(unsigned char));
    readBytesCount = [self retryReadBuffer:_response withSize:_responseSize usingSocketDescriptor:socketDescriptor];
    if (readBytesCount != _responseSize) {
        SAFEFREE(_response);
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:readBytesCount], @"readBytesCount", nil];
        @throw [NSException exceptionWithName:@"GTNetworkException" reason:@"Cannot receive response" userInfo:dictionary];
    }
    *response = _response;
    *size = _responseSize;
}

- (void)processRequest:(unsigned char *)request withRequestSize:(long)requestSize withHeaderSize:(int)headerSize onHost:(NSString *)host withPort:(int)port withResponse:(unsigned char **)response withResponseSize:(long *)responseSize
{
    int socketDescriptor = [self createSocketDescriptorAndConnectToHost:host withPort:port];
    [self sendRequest:request withSize:requestSize andHeaderSize:headerSize usingSocketDescriptor:socketDescriptor];
    [self receiveResponse:response withSize:responseSize usingSocketDescriptor:socketDescriptor];
    [self closeSocketDescriptor:socketDescriptor];
}

@end
