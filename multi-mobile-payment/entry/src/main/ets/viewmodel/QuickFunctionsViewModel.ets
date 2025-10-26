/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { QuickFunctionItem } from './PayHubViewModel';

export class QuickFunctionsViewModel {
  private quickFunctions: QuickFunctionItem[] = [];

  constructor() {
    this.quickFunctions.push(new QuickFunctionItem($r('app.media.scan'), $r('app.string.scan')));
    this.quickFunctions.push(new QuickFunctionItem($r('app.media.payment_code'), $r('app.string.pay_and_receive')));
    this.quickFunctions.push(new QuickFunctionItem($r('app.media.travel'), $r('app.string.travel')));
    this.quickFunctions.push(new QuickFunctionItem($r('app.media.card_holder'), $r('app.string.card_package')));
  }

  public getQuickFunctions(): QuickFunctionItem[] {
    return this.quickFunctions;
  }
}