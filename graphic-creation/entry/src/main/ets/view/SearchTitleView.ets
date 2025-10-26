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
import { CommonConstants } from '../common/CommonConstants';

@Component
export struct SearchTitleView {
  @StorageLink(CommonConstants.BREAKPOINT_NAME) currentBreakpoint: string = CommonConstants.BREAKPOINT_SM;

  build() {
    if (this.currentBreakpoint === CommonConstants.BREAKPOINT_SM) {
      Row() {
        Image($r('sys.media.ohos_ic_public_search_filled'))
          .width($r('app.float.icon_size_24'))
          .height($r('app.float.icon_size_24'))
      }

    } else {
      Flex({
        direction: FlexDirection.Row,
        wrap: FlexWrap.NoWrap,
        justifyContent: FlexAlign.Start,
        alignItems: ItemAlign.Center,
        alignContent: FlexAlign.Center
      }) {
        Image($r('sys.media.ohos_ic_public_search_filled'))
          .objectFit(ImageFit.Cover)
          .width($r('app.float.icon_size_16'))
          .height($r('app.float.icon_size_16'))
          .fillColor($r('sys.color.ohos_id_color_text_secondary'))
          .margin({ left: $r('app.float.margin_14'), right: $r('app.float.margin_14') })

        Text($r('app.string.search_hold'))
          .alignSelf(ItemAlign.Center)
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .fontSize($r('sys.float.ohos_id_text_size_button1'))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .width($r('app.float.flow_item_height_min'))

        Image($r('app.media.mic'))
          .objectFit(ImageFit.Cover)
          .width($r('app.float.icon_size_16'))
          .height($r('app.float.icon_size_16'))
          .fillColor($r('sys.color.ohos_id_color_text_secondary'))
          .margin({ right: $r('app.float.margin_14') })
      }
      .clip(true)
      .borderRadius($r('sys.float.ohos_id_corner_radius_default_xl'))
      .width($r('app.float.search_title_width'))
      .height($r('app.float.search_title_height'))
      .backgroundColor($r('sys.color.ohos_id_color_component_normal'))
    }
  }
}