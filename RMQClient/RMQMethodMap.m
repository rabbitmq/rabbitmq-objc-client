// This source code is dual-licensed under the Mozilla Public License ("MPL"),
// version 1.1 and the Apache License ("ASL"), version 2.0.
//
// The ASL v2.0:
//
// ---------------------------------------------------------------------------
// Copyright 2017-2019 Pivotal Software, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ---------------------------------------------------------------------------
//
// The MPL v1.1:
//
// ---------------------------------------------------------------------------
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// https://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//
// The Original Code is RabbitMQ
//
// The Initial Developer of the Original Code is Pivotal Software, Inc.
// All Rights Reserved.
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

// This file is generated. Do not edit.
#import "RMQMethodMap.h"
#import "RMQMethods.h"

@implementation RMQMethodMap
+ (NSDictionary *)methodMap {
    return @{@[@(10), @(10)] : [RMQConnectionStart class],
             @[@(10), @(11)] : [RMQConnectionStartOk class],
             @[@(10), @(20)] : [RMQConnectionSecure class],
             @[@(10), @(21)] : [RMQConnectionSecureOk class],
             @[@(10), @(30)] : [RMQConnectionTune class],
             @[@(10), @(31)] : [RMQConnectionTuneOk class],
             @[@(10), @(40)] : [RMQConnectionOpen class],
             @[@(10), @(41)] : [RMQConnectionOpenOk class],
             @[@(10), @(50)] : [RMQConnectionClose class],
             @[@(10), @(51)] : [RMQConnectionCloseOk class],
             @[@(10), @(60)] : [RMQConnectionBlocked class],
             @[@(10), @(61)] : [RMQConnectionUnblocked class],
             @[@(20), @(10)] : [RMQChannelOpen class],
             @[@(20), @(11)] : [RMQChannelOpenOk class],
             @[@(20), @(20)] : [RMQChannelFlow class],
             @[@(20), @(21)] : [RMQChannelFlowOk class],
             @[@(20), @(40)] : [RMQChannelClose class],
             @[@(20), @(41)] : [RMQChannelCloseOk class],
             @[@(40), @(10)] : [RMQExchangeDeclare class],
             @[@(40), @(11)] : [RMQExchangeDeclareOk class],
             @[@(40), @(20)] : [RMQExchangeDelete class],
             @[@(40), @(21)] : [RMQExchangeDeleteOk class],
             @[@(40), @(30)] : [RMQExchangeBind class],
             @[@(40), @(31)] : [RMQExchangeBindOk class],
             @[@(40), @(40)] : [RMQExchangeUnbind class],
             @[@(40), @(51)] : [RMQExchangeUnbindOk class],
             @[@(50), @(10)] : [RMQQueueDeclare class],
             @[@(50), @(11)] : [RMQQueueDeclareOk class],
             @[@(50), @(20)] : [RMQQueueBind class],
             @[@(50), @(21)] : [RMQQueueBindOk class],
             @[@(50), @(50)] : [RMQQueueUnbind class],
             @[@(50), @(51)] : [RMQQueueUnbindOk class],
             @[@(50), @(30)] : [RMQQueuePurge class],
             @[@(50), @(31)] : [RMQQueuePurgeOk class],
             @[@(50), @(40)] : [RMQQueueDelete class],
             @[@(50), @(41)] : [RMQQueueDeleteOk class],
             @[@(60), @(10)] : [RMQBasicQos class],
             @[@(60), @(11)] : [RMQBasicQosOk class],
             @[@(60), @(20)] : [RMQBasicConsume class],
             @[@(60), @(21)] : [RMQBasicConsumeOk class],
             @[@(60), @(30)] : [RMQBasicCancel class],
             @[@(60), @(31)] : [RMQBasicCancelOk class],
             @[@(60), @(40)] : [RMQBasicPublish class],
             @[@(60), @(50)] : [RMQBasicReturn class],
             @[@(60), @(60)] : [RMQBasicDeliver class],
             @[@(60), @(70)] : [RMQBasicGet class],
             @[@(60), @(71)] : [RMQBasicGetOk class],
             @[@(60), @(72)] : [RMQBasicGetEmpty class],
             @[@(60), @(80)] : [RMQBasicAck class],
             @[@(60), @(90)] : [RMQBasicReject class],
             @[@(60), @(100)] : [RMQBasicRecoverAsync class],
             @[@(60), @(110)] : [RMQBasicRecover class],
             @[@(60), @(111)] : [RMQBasicRecoverOk class],
             @[@(60), @(120)] : [RMQBasicNack class],
             @[@(90), @(10)] : [RMQTxSelect class],
             @[@(90), @(11)] : [RMQTxSelectOk class],
             @[@(90), @(20)] : [RMQTxCommit class],
             @[@(90), @(21)] : [RMQTxCommitOk class],
             @[@(90), @(30)] : [RMQTxRollback class],
             @[@(90), @(31)] : [RMQTxRollbackOk class],
             @[@(85), @(10)] : [RMQConfirmSelect class],
             @[@(85), @(11)] : [RMQConfirmSelectOk class]};
}
@end
