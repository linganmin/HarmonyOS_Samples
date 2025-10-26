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

import { liveViewManager } from '@kit.LiveViewKit';
import { WantAgent } from '@kit.AbilityKit';
import { CyclingConstants } from '../constants/CyclingConstants';

type LiveViewData = liveViewManager.LiveViewData;
let parameters: Record<string, string> = { '': '' }

export class LiveViewDataBuilder implements LiveViewData {
  public primary: liveViewManager.PrimaryData;
  public capsule?: liveViewManager.TextCapsule;
  public external?: liveViewManager.ExternalData;

  constructor() {
    // [Start primary]
    this.primary = {
      title: '',
      content: [
        {
          text: '',
          textColor: ''
        }
      ],
      keepTime: CyclingConstants.KEEP_TIME,
      clickAction: undefined,
      layoutData: undefined,
      liveViewLockScreenPicture: 'icBike.png',
      liveViewLockScreenAbilityName: 'LiveViewLockScreenExtAbility',
      liveViewLockScreenAbilityParameters: parameters
    };
    // [End primary]
  }

  public setTitle(title: string) {
    this.primary.title = title;
    return this;
  }

  public setContentText(contentText: string) {
    this.primary.content![0].text = contentText;
    return this;
  }

  public setLayoutData(layoutData: liveViewManager.PickupLayout) {
    this.primary.layoutData = layoutData;
    return this;
  }

  public setCapsule(capsule: liveViewManager.TextCapsule) {
    this.capsule = capsule;
    return this;
  }

  public setContentColor(contentColor: string) {
    this.primary.content![0].textColor = contentColor;
    return this;
  }

  public setWant(wantAgent: WantAgent) {
    this.primary.clickAction = wantAgent;
    return this;
  }
}
