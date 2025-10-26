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

type TextCapsule = liveViewManager.TextCapsule;

export class TextCapsuleBuilder implements TextCapsule {
  public type: liveViewManager.CapsuleType = liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT;
  public status: number = 1;
  public icon?: string;
  public backgroundColor?: string;
  public title?: string;
  public content?: string;

  public setStatus(status: number) {
    this.status = status;
    return this;
  }

  public setIcon(icon: string) {
    this.icon = icon;
    return this;
  }

  public setBackgroundColor(backgroundColor: string) {
    this.backgroundColor = backgroundColor;
    return this;
  }

  public setTitle(title: string) {
    this.title = title;
    return this;
  }

  public setContent(content: string) {
    this.content = content;
    return this;
  }
}
