/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { HMActionType, HMInterceptorAction, HMInterceptorInfo, IHMInterceptor,
  IHMInterceptorChain } from '@hadss/hmrouter';

export class JumpInfoInterceptor implements IHMInterceptor {
  async intercept(chain: IHMInterceptorChain): Promise<void> {
    const info = chain.getRouterInfo();
    const context = chain.getContext();
    let connectionInfo: string = '';
    if(info.type === HMActionType.PUSH) {
      connectionInfo = 'jump to';
    } else {
      connectionInfo = 'back to';
    }
    console.log(`${info.srcName} ${connectionInfo} ${info.targetName}`);
    await chain.onContinue()
  }
}