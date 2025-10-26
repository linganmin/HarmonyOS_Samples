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
import { WaterFlowData } from '../model/WaterFlowDataSource';
import { DataUtils } from '../utils/DataUtils';
import Logger from '../utils/Logger';

@Reusable
@Component
export struct FlowItemView {
  @State data: WaterFlowData | undefined = undefined;
  private static readonly tag: string = 'FlowItemView';

  aboutToReuse(params: Record<string, WaterFlowData>): void {
    this.data = params.data;
  }

  build() {
    Flex(
      {
        direction: FlexDirection.Column,
        wrap: FlexWrap.NoWrap,
        justifyContent: FlexAlign.Start,
        alignItems: ItemAlign.Center,
        alignContent: FlexAlign.Center
      }
    ) {
      Image(this.data?.coverPath)
        .objectFit(ImageFit.Cover)
        .width($r('app.string.full_screen'))
        .onError((error: ImageError) => {
          Logger.error(FlowItemView.tag, `Image load error:${error.message}`);
        })

      Column({ space: DataUtils.fromResToNumber($r('app.float.space_8')) }) {
        Row() {
          Text(this.data?.descriptions)
            .fontSize($r('app.float.font_size_14'))
            .lineHeight($r('app.float.line_height_16'))
            .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
            .maxLines(1);
        }
        .width($r('app.string.full_screen'))
        .margin({ left: $r('app.float.margin_24') })

        Row() {
          Row({ space: DataUtils.fromResToNumber($r('app.float.space_4')) }) {
            Text(this.data?.author)
              .fontSize($r('app.float.font_size_10'))
              .lineHeight($r('app.float.line_height_12'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
              .fontColor(Color.Black)
              .opacity($r('app.float.opacity_percent_60'))
          }
          .margin({ left: $r('app.float.margin_12') })

          Row({ space: DataUtils.fromResToNumber($r('app.float.space_2')) }) {
            Image($r('app.media.ic_public_favor'))
              .fillColor(Color.Black)
              .objectFit(ImageFit.Fill)
              .width($r('app.float.circular_size_16'))
              .height($r('app.float.circular_size_16'))
            Text(this.data?.favorites)
              .fontSize($r('app.float.font_size_12'))
              .lineHeight($r('app.float.line_height_14'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
              .fontColor(Color.Black)
              .opacity($r('app.float.opacity_percent_60'))
          }.alignSelf(ItemAlign.End)
          .margin({ right: $r('app.float.margin_12') })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width($r('app.string.full_screen'))

      }.margin({
        left: $r('app.float.margin_12'),
        right: $r('app.float.margin_12'),
        top: $r('app.float.margin_12'),
        bottom: $r('app.float.margin_10')
      }).width($r('app.string.full_screen'))
    }
    .width($r('app.string.full_screen'))
  }
}