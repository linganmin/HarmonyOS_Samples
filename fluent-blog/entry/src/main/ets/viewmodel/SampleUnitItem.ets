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

import { AVPlayerItem } from '../view/AVPlayerItem';
import ButtonUnitItem from './ButtonUnitItem';
import TitleUnitItem from './TitleUnitItem';

export default class SampleUnitItem {
  public type: string;
  public title: TitleUnitItem;
  public context: string;
  public button: ButtonUnitItem;
  public pic?: Resource[];
  public controller?: VideoController;
  public avPlayer?: AVPlayerItem;

  constructor(type: string, title: TitleUnitItem, context: string, button: ButtonUnitItem, pic: Resource[], controller: VideoController, avPlayer: AVPlayerItem) {
    this.type = type;
    this.title = title;
    this.context = context;
    this.button = button;
    this.pic = pic;
    this.controller = controller;
    this.avPlayer = avPlayer;
  }
}