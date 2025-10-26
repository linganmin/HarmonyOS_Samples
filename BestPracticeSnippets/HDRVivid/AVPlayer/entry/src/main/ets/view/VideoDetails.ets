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
import { CommonConstants as Const, VideoData } from '@ohos/MediaService';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component({ freezeWhenInactive: true })
export struct VideoDetails {
  @Prop item: VideoData;
  @State isFollow: boolean = true;
  @State isLike: boolean = false;
  uiContext = this.getUIContext()
  getPromptAction = this.uiContext.getPromptAction()

  /**
   * The callback function for the click event of the like button.
   * @param isAdd
   */
  private changeLikeCount(isAdd: boolean) {
    let likeCountNum = Number(this.item.likeCount);
    if (isAdd) {
      likeCountNum++;
    } else {
      likeCountNum--;
    }
    this.item.likeCount = '' + likeCountNum;
    this.uiContext.animateTo({ duration: Const.DURATION, curve: Curve.EaseInOut }, () => {
      this.isLike = !this.isLike;
    })
  }

  build() {
    Column() {
      Row() {
        Image(this.item.head)
          .width($r('app.float.avatar_size'))
          .height($r('app.float.avatar_size'))
          .borderRadius($r('app.float.avatar_borderRadius'))
        Column() {
          Text(this.item.name)
            .fontSize($r('app.float.name_font_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.Black)
            .opacity($r('app.float.opacity_9'))
          Text($r('app.string.user_followers'))
            .margin({ top: $r('app.float.video_des_margin_bottom') })
            .fontSize($r('app.float.font_size_12'))
            .fontColor(Color.Black)
            .opacity($r('app.float.opacity_6'))
        }
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        .padding({ left: $r('app.float.image_padding') })

        Blank()

        Button() {
          Text($r('app.string.user_follow'))
            .fontSize($r('app.float.font_size_14'))
            .fontColor($r('sys.color.white'))
            .textAlign(TextAlign.Center)
            .width($r('app.float.button_content_width'))
            .height($r('app.float.button_content_height'))
        }
        .padding({
          left: $r('app.float.margin_small'),
          right: $r('app.float.margin_small'),
          top: $r('app.float.margin_4'),
          bottom: $r('app.float.margin_4')
        })
        .backgroundColor($r('app.color.button_fill_color'))
        .onClick(() => {
          this.uiContext.animateTo({ duration: Const.DURATION, curve: Curve.EaseInOut }, () => {
            this.isFollow = !this.isFollow;
          });
        })
      }
      .width(Const.FULL_SIZE)
      .alignItems(VerticalAlign.Center)
      .padding({
        bottom: $r('app.float.padding_11')
      })

      Text(this.item.description)
        .fontSize($r('app.float.font_size_18'))
        .fontColor(Color.Black)
        .opacity($r('app.float.opacity_9'))
        .maxLines(2)
        .padding({
          bottom: $r('app.float.padding_12')
        })
        .alignSelf(ItemAlign.Start)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Row() {
        Column() {
          Image($r('app.media.ic_detail_favor_filled'))
            .height($r('app.float.size_24'))
            .width($r('app.float.size_24'))
            .fillColor(this.isLike ? Color.Red : $r('app.color.image_fill_color'))
            .opacity($r('app.float.opacity_6'))
            .margin({ bottom: $r('app.float.fabulous_margin_bottom') })
          Text(this.item.likeCount)
            .fontSize($r('app.float.fabulous_font_size'))
            .fontColor(Color.Black)
            .opacity($r('app.float.opacity_4'))
        }
        .onClick(() => {
          this.changeLikeCount(!this.isLike);
        })

        Column() {
          Image($r('app.media.ic_detail_comments_filled'))
            .height($r('app.float.size_24'))
            .width($r('app.float.size_24'))
            .margin({ bottom: $r('app.float.fabulous_margin_bottom') })
          Text(this.item.commentCount)
            .fontSize($r('app.float.fabulous_font_size'))
            .fontColor(Color.Black)
            .opacity($r('app.float.opacity_4'))
        }
        .onClick(() => {
          try {
            this.getPromptAction.showToast({ message: $r('app.string.comment'), duration: Const.TOAST_DURATION })
          } catch (error) {
            hilog.error(0x0000, 'testTag',`getPromptAction showToast failed, Code:${error.code}, message:${error.message}`);
          }
        })

        Column() {
          Image($r('app.media.ic_detail_share_filled'))
            .height($r('app.float.size_24'))
            .width($r('app.float.size_24'))
            .margin({ bottom: $r('app.float.fabulous_margin_bottom') })
          Text(this.item.shareCount)
            .fontSize($r('app.float.fabulous_font_size'))
            .fontColor(Color.Black)
            .opacity($r('app.float.opacity_4'))
        }
        .onClick(() => {
          try {
            this.getPromptAction.showToast({ message: $r('app.string.share'), duration: Const.TOAST_DURATION });
          } catch (error) {
            hilog.error(0x0000, 'testTag',`getPromptAction showToast failed, Code:${error.code}, message:${error.message}`);
          }
        })
      }
      .width(Const.FULL_SIZE)
      .padding({ left: $r('app.float.space_30'), right: $r('app.float.space_30') })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)

    }
    .width(Const.WIDTH_FULL_PERCENT)
    .padding({
      top: $r('app.float.padding_12'),
      bottom: $r('app.float.padding_12'),
      left: $r('app.float.padding_16'),
      right: $r('app.float.padding_16'),
    })
  }
}