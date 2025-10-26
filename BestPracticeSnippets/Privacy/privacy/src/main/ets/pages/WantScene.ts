/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AbilityConstant, Want } from '@kit.AbilityKit';
import { rpc } from '@kit.IPCKit';

interface WantScene {
  /**
   * 最佳实践：应用安全编码实践
   * 场景二十七：建议对跨信任边界传入的Want进行合法性判断-在不同场景下获取Want的方式
   */

  // [Start want_scene]
  // Application life cycle:
  // @ohos.application.AbilityStage.d.ts
  onAcceptWant(want: Want): string;
  // ability life cycle：
  // @ohos.application.Ability.d.ts
  onCreate(want: Want, param: AbilityConstant.LaunchParam): void;
  onContinue(wantParam: {}): AbilityConstant.OnContinueResult;
  onNewWant(want: Want, launchParams: AbilityConstant.LaunchParam): void;
  // ServiceExtensionAbility life cycle：
  // @ohos.application.ServiceExtensionAbility.d.ts
  onCreate(want: Want): void;
  onRequest(want: Want, startId: number): void;
  onConnect(want: Want): rpc.RemoteObject;
  onDisconnect(want: Want): void;
  onReconnect(want: Want): void;
  // [End want_scene]
}