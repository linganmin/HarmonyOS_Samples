/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { image } from '@kit.ImageKit';
import { CommonConstants } from '../common/constants/CommonConstants';
import { VideoData } from '../model/VideoData';
import { ImageUtil } from '../common/utils/ImageUtil';
import { VideoDataType } from '../common/constants/CommonConstants';

@Component({ freezeWhenInactive: true })
export struct VideoList {
  @Link currentIndex: number; // The index of playing video
  @Prop sources: VideoData[];
  onItemClick?: (index: number) => void = () => {
  };
  @State pixelMaps: image.PixelMap | undefined[] = [];

  async aboutToAppear(): Promise<void> {
    for (let index = 1; index < this.sources.length; index++) {
      let url: string = this.sources[index].videoSrc;
      let pixelMap = await ImageUtil.getThumbnailFromVideo(url, 500); // Get first frame image from each video
      this.pixelMaps[index] = pixelMap;
    }
  }

  build() {
    Column() {
      Text($r('app.string.videoList'))
        .fontSize($r('app.float.font_size_18'))
        .fontColor($r('app.color.dialog_text_color'))
        .alignSelf(ItemAlign.Start)
        .padding({ top: $r('app.float.padding_14'), bottom: $r('app.float.padding_14') })
        .fontWeight(FontWeight.Bold)
        .opacity($r('app.float.opacity_9'))

      Scroll() {
        List({ space: CommonConstants.LIST_SPACE }) {
          ForEach(this.sources, (item: VideoData, index: number) => {
            ListItem() {
              Flex({ direction: FlexDirection.Row }) {
                Image(this.pixelMaps[index] || $r('app.media.preview1'))
                  .height($r('app.float.list_img_height'))
                  .width($r('app.float.list_img_width'))
                  .objectFit(ImageFit.Cover)
                  .borderRadius($r('app.float.list_img_radius'))
                Column() {
                  Text() {
                    if (index === this.currentIndex) {
                      SymbolSpan($r('sys.symbol.play_round_rectangle_fill'))
                        .width($r('app.float.size_20'))
                        .height($r('app.float.size_20'))
                    } // Whether is the current playing video
                    Span((index + 1) + '.')
                    Span(
                      (item.type === VideoDataType.RAW_FILE ? $r('app.string.local_video') :
                        $r('app.string.online_video'))) // Video type
                    Span(item.description) // Video description
                  }
                  .fontSize($r('app.float.font_size_14'))
                  .fontWeight(FontWeight.Medium)
                  .width(CommonConstants.WIDTH_FULL_PERCENT)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .opacity($r('app.float.opacity_9'))
                  .fontColor(index === this.currentIndex ? $r('app.color.dialog_cancel_color') :
                    $r('app.color.dialog_text_color'))
                }
                .height($r('app.float.list_img_height'))
                .margin({ left: 12 })
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .height(80)
              .width(CommonConstants.WIDTH_FULL_PERCENT)
              .onClick(() => {
                this.onItemClick?.(index);
              })
            }
          }, (item: VideoData, index: number) => index + JSON.stringify(item))
        }
        .height(CommonConstants.HEIGHT_FULL_PERCENT)
        .width(CommonConstants.WIDTH_FULL_PERCENT)
        .listDirection(Axis.Vertical)
        .margin({
          top: $r('app.float.padding_12'),
          bottom: (AppStorage.get<number>('navBarHeight') || 0) + CommonConstants.SPACE_16
        })
        .scrollBar(BarState.Off)
      }
      .scrollBar(BarState.Off)
    }
    .padding({ left: $r('app.float.padding_16'), right: $r('app.float.padding_16') })
  }
}