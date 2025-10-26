/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
import { emitter } from '@kit.BasicServicesKit';

/*
* FAQ:emitter.off取消订阅某个事件后，是不是所有订阅该事件的地方都不会再收到该事件的消息
 */

// [Start emitterOff]
emitter.off(1);
// [End emitterOff]