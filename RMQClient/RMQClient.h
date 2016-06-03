#import <UIKit/UIKit.h>
#import <RMQClient/RMQConnection.h>
#import <RMQClient/RMQErrors.h>
#import <RMQClient/RMQBasicProperties.h>
#import <RMQClient/RMQFrame.h>
#import <RMQClient/RMQHeartbeat.h>
#import <RMQClient/RMQMethodDecoder.h>
#import <RMQClient/RMQMethodMap.h>
#import <RMQClient/RMQProtocolHeader.h>
#import <RMQClient/RMQURI.h>
#import <RMQClient/RMQAllocatedChannel.h>
#import <RMQClient/RMQConnectionDelegateLogger.h>
#import <RMQClient/RMQConnectionRecover.h>
#import <RMQClient/RMQSuspendResumeDispatcher.h>
#import <RMQClient/RMQFramesetValidator.h>
#import <RMQClient/RMQHandshaker.h>
#import <RMQClient/RMQMultipleChannelAllocator.h>
#import <RMQClient/RMQReader.h>
#import <RMQClient/RMQSynchronizedMutableDictionary.h>
#import <RMQClient/RMQTCPSocketTransport.h>
#import <RMQClient/RMQUnallocatedChannel.h>
#import <RMQClient/RMQGCDSerialQueue.h>
#import <RMQClient/RMQSemaphoreWaiterFactory.h>
#import <RMQClient/RMQSemaphoreWaiter.h>
#import <RMQClient/RMQProcessInfoNameGenerator.h>
#import <RMQClient/RMQQueuingConnectionDelegateProxy.h>
#import <RMQClient/RMQGCDHeartbeatSender.h>
#import <RMQClient/RMQTickingClock.h>
#import <RMQClient/RMQPKCS12CertificateConverter.h>
#import <RMQClient/RMQTLSOptions.h>

//! Project version number for RMQClient.
FOUNDATION_EXPORT double RMQClientVersionNumber;

//! Project version string for RMQClient.
FOUNDATION_EXPORT const unsigned char RMQClientVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <RMQClient/PublicHeader.h>


