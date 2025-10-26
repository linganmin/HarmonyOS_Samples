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

import ButtonUnitItem from '../viewmodel/ButtonUnitItem';
import TitleUnitItem from '../viewmodel/TitleUnitItem';
import { AVPlayerItem } from './AVPlayerItem';
import ButtonItem from './ButtonItem';
import TitleAreaItem from './TitleAreaItem';
import SampleUnitPicView from './SampleUnitPicView';
import SampleUnitVideoView from './SampleUnitVideoView';
import { CONSTANT } from '../constant/Constant';
import SampleUnitVideoSecondView from './SampleUnitVideoSecondView';

// Font family
const FONT_FAMILY = 'HarmonyHeiTi';
// Margin about
const STATIC_MARGIN = 8;
const MINI_MARGIN = 4;
// All types
const TYPE_ENUM = ['av', 'pic', 'video'];
// Font weight.
const FONT_WEIGHT = 400;
// Border radius
const BORDER_RADIUS = 5;

@Component
export default struct SampleUnitView {
  @Prop areaUnit: TitleUnitItem;
  @Prop buttonUnit: ButtonUnitItem;
  @Prop type: string;
  @Prop textContext: string;
  @Prop imageArray: Resource[];
  controller: VideoController = new VideoController();
  avPlayer: AVPlayerItem = new AVPlayerItem();

  build() {
    Flex({ direction: FlexDirection.Column }) {
      TitleAreaItem({ unit: this.areaUnit })
      Text(this.textContext)
        .fontSize(CONSTANT.FONT_SIZE_FOURTEEN)
        .fontWeight(FONT_WEIGHT)
        .textAlign(TextAlign.JUSTIFY)
        .fontFamily(FONT_FAMILY)
        .margin({ bottom: STATIC_MARGIN })
      if (this.type === TYPE_ENUM[0]) {
        SampleUnitVideoSecondView({ controller: this.controller });
      } else if (this.type === TYPE_ENUM[1]) {
        SampleUnitPicView({ imageArray: this.imageArray });
      } else if (this.type === TYPE_ENUM[2]) {
        SampleUnitVideoView({ controller: this.controller });
      }
      Column() {
        ButtonItem({ unit: this.buttonUnit })
      }
      .margin({ bottom: STATIC_MARGIN, top: STATIC_MARGIN })
    }
    .margin({ left: MINI_MARGIN, right: MINI_MARGIN })
    .backgroundColor(Color.White)
    .borderRadius(BORDER_RADIUS)
  }
}