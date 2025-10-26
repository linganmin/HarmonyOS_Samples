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

import { CustomTransition } from './CustomNavigationUtils';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
@Observed
export class PrePageInteractiveTransitionProperties {
  public translateX: number | string = 0;

  public doAnimation(transitionProxy: NavigationTransitionProxy): void {
    if (CustomTransition.getInstance().operation === NavigationOperation.PUSH) {
      this.translateX = 0;
      uiContext?.animateTo({
        duration: 300, onFinish: () => {
          transitionProxy.finishTransition();
        }
      }, () => {
        this.translateX = '-20%';
      })
    } else if (CustomTransition.getInstance().operation === NavigationOperation.POP) {
      this.translateX = '-20%';
      uiContext?.animateTo({
        duration: 300, onFinish: () => {
          transitionProxy.finishTransition();
        }
      }, () => {
        this.translateX = 0;
      })
    }
  }

  public onInteractiveFinish(): void {
    this.translateX = 0;
  }

  public onInteractive(): void {
    if (CustomTransition.getInstance().operation === NavigationOperation.PUSH) {
      this.translateX = 0;
      uiContext?.animateTo({
        duration: 1000,
      }, () => {
        this.translateX = '-20%';
      })
    } else {
      this.translateX = '-20%';
      uiContext?.animateTo({
        duration: 1000,
      }, () => {
        this.translateX = 0;
      })
    }
  }
}