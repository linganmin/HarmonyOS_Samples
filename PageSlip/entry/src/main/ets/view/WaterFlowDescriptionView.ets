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

import { CommonConstants } from '../constants/CommonConstants';

@Component
export struct WaterFlowDescriptionView {
  @Link title: string;
  @Link userImage: string;
  @Link userName: string;
  @Link type: string;
  @Link collectionsCount: number;
  @Link vipSign: string;

  build() {
    Column() {
      Text(this.title)
        .fontSize($r('app.float.font_size_14'))
        .fontWeight(CommonConstants.TEXT_FONT_WEIGHT_500)
        .width($r('app.string.full_screen'))
        .maxLines(CommonConstants.TEXT_MAX_LINES)
        .textOverflow({ overflow: TextOverflow.Ellipsis });
      Row() {
        Row() {
          Stack({ alignContent: Alignment.BottomEnd }) {
            Image(this.userImage)
              .width($r('app.float.photo_size_16'))
              .height($r('app.float.photo_size_16'))
              .borderRadius($r('app.float.user_image_photo_radius'));
            if (this.vipSign === CommonConstants.VIP_SIGN) {
              Image($r('app.media.V')).zIndex(CommonConstants.LARGE_INDEX)
                .width($r('app.float.photo_size_8'))
                .height($r('app.float.photo_size_8'))
                .borderRadius($r('app.float.user_image_vip_radius'));
            }
          };

          Text(this.userName)
            .fontSize($r('app.float.font_size_10'))
            .fontWeight(CommonConstants.TEXT_FONT_WEIGHT_400)
            .fontColor(Color.Black)
            .opacity($r('app.float.opacity_percent_60'))
            .margin({ left: 4 });
        }
        .justifyContent(FlexAlign.Center);


        Blank();

        Row() {
          Stack() {
            Image('living' === this.type ? $r('app.media.people') : $r('app.media.ic_public_heart'))
              .fillColor(Color.Black)
              .objectFit(ImageFit.Fill)
              .width($r('app.float.photo_size_width'))
              .height($r('app.float.photo_size_height'))
              .onClick(() => {
                this.collectionsCount++;
              });
          };

          Text(this.collectionsCount < 1000 ? this.collectionsCount + '' :
            (this.collectionsCount / 1000).toFixed(1) + 'k')
            .fontSize($r('app.float.font_size_12'))
            .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
            .fontColor(Color.Black)
            .opacity($r('app.float.opacity_percent_60'))
            .margin({ left: $r('app.float.margin_4') });
        };
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width($r('app.string.full_screen'))
      .margin({ top: $r('app.float.margin_8') });
    }
    .padding({
      left: $r('app.float.margin_12'),
      right: $r('app.float.margin_12'),
      top: $r('app.float.margin_12'),
      bottom: $r('app.float.margin_10')
    })
    .width($r('app.string.full_screen'));
  }
}