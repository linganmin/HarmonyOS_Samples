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

type PickupLayout = liveViewManager.PickupLayout;

export class TextLayoutBuilder implements PickupLayout {
  public layoutType: liveViewManager.LayoutType = liveViewManager.LayoutType.LAYOUT_TYPE_PICKUP;
  public title?: string;
  public content?: string;
  public underlineColor?: string = '#00000000';
  public descPic?: string;

  public setTitle(title: string) {
    this.title = title;
    return this;
  }

  public setContent(content: string) {
    this.content = content;
    return this;
  }

  public setUnderlineColor(underlineColor: string) {
    this.underlineColor = underlineColor;
    return this;
  }

  public setDescPic(descPic: string) {
    this.descPic = descPic;
    return this;
  }
}