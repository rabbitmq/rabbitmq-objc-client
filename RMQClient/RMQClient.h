// This source code is dual-licensed under the Mozilla Public License ("MPL"),
// version 2.0 and the Apache License ("ASL"), version 2.0.
//
// The ASL v2.0:
//
// ---------------------------------------------------------------------------
// Copyright (c) 2007-2024 Broadcom. All Rights Reserved. The term “Broadcom” refers to Broadcom Inc. and/or its subsidiaries. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ---------------------------------------------------------------------------
//
// The MPL v2.0:
//
// ---------------------------------------------------------------------------
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2007-2022 VMware, Inc. or its affiliates.  All rights reserved.
//
// Alternatively, the contents of this file may be used under the terms
// of the Apache Standard license (the "ASL License"), in which case the
// provisions of the ASL License are applicable instead of those
// above. If you wish to allow use of your version of this file only
// under the terms of the ASL License and not to allow others to use
// your version of this file under the MPL, indicate your decision by
// deleting the provisions above and replace them with the notice and
// other provisions required by the ASL License. If you do not delete
// the provisions above, a recipient may use your version of this file
// under either the MPL or the ASL License.
// ---------------------------------------------------------------------------

#import <RMQClient/RMQConnection.h>
#import <RMQClient/RMQErrors.h>
#import <RMQClient/RMQBasicProperties.h>
#import <RMQClient/RMQBasicProperties+MergeDefaults.h>
#import <RMQClient/RMQFrame.h>
#import <RMQClient/RMQHeartbeat.h>
#import <RMQClient/RMQMethodDecoder.h>
#import <RMQClient/RMQMethodMap.h>
#import <RMQClient/RMQMethods+Convenience.h>
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
#import <RMQClient/RMQTransactionalConfirmations.h>
#import <RMQClient/RMQConfirmationTransaction.h>

//! Project version number for RMQClient.
FOUNDATION_EXPORT double RMQClientVersionNumber;

//! Project version string for RMQClient.
FOUNDATION_EXPORT const unsigned char RMQClientVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <RMQClient/PublicHeader.h>


