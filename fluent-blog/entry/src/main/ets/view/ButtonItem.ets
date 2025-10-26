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
import { CONSTANT } from '../constant/Constant';
import ButtonUnitItem from '../viewmodel/ButtonUnitItem';

// Static height
const STATIC_HEIGHT = 20;
// Row height
const ROW_HEIGHT = 40;
// Static margin
const STATIC_MARGIN = 10;

@Component
export default struct ButtonItem {
  @Prop unit: ButtonUnitItem;

  build() {
    Row() {
      Row() {
        Image(this.unit.buttonRecommendsImg)
          .height(STATIC_HEIGHT)
          .objectFit(ImageFit.Contain)
      }

      Row() {
        Image($r('app.media.comment'))
          .height(STATIC_HEIGHT)
          .objectFit(ImageFit.Contain)
      }

      Row() {
        Image(this.unit.buttonCommentaryImg)
          .height(STATIC_HEIGHT)
          .objectFit(ImageFit.Contain)
      }

      Row() {
        Image(this.unit.buttonLikesImg)
          .height(STATIC_HEIGHT)
          .objectFit(ImageFit.Contain)
      }
    }
    .height(ROW_HEIGHT)
    .width(CONSTANT.FULL_SIZE)
    .justifyContent(FlexAlign.SpaceAround)
    .margin({ left: STATIC_MARGIN, right: STATIC_MARGIN })

  }
}