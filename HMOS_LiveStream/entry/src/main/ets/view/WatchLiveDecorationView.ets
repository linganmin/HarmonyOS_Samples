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

import { COMMENT_LIST } from '../common/CommonConstants';
import Logger from '../common/utils/Logger';
import { CommentDataModel } from '../pages/WatchLiveStream';

const TAG = "[WatchLiveDecorationView]";

@Component
export struct WatchLiveDecorationView {
  @Consume('pageStack') pageStack: NavPathStack;
  @Link isFollowed: boolean;
  @Link isLiked: boolean;
  @Link @Watch('onLiveListUpdated') liveList: Array<CommentDataModel>;
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.updateCommentList();
  }

  onLiveListUpdated(): void {
    let i = 0;
    let intervalID = setInterval(() => {
      i++;
      this.scroller.scrollPage({ next: true });
      if (i === this.liveList?.length) {
        clearInterval(intervalID);
      }
    }, 100);
  }

  updateCommentList() {
    let i = 0;
    let intervalID = setInterval(() => {
      this.liveList.push(COMMENT_LIST[i++]);
      if (i === COMMENT_LIST.length) {
        clearInterval(intervalID);
      }
    }, 1000);
  }

  @Builder
  TopBar() {
    Row() {
      Row() {
        Row() {
          Image($r('app.media.live_author'))
            .width('32vp')
            .height('32vp')

          Column() {
            Text($r('app.string.author_name'))
              .fontSize('12fp')
              .lineHeight('16vp')
              .fontFamily('HarmonyHeiTi')
              .fontWeight(700)
              .fontColor($r('sys.color.comp_background_list_card'))
              .textOverflow({ overflow: TextOverflow.MARQUEE })
              .width('50vp')
            Row() {
              Text($r('app.string.number_of_people'))
                .fontSize('10fp')
                .lineHeight('13vp')
                .fontFamily('HarmonyHeiTi')
                .fontWeight(400)
                .fontColor($r('sys.color.comp_background_list_card'))
              Text($r('app.string.watch'))
                .fontSize('10fp')
                .lineHeight('13vp')
                .fontFamily('HarmonyHeiTi')
                .fontWeight(400)
                .fontColor($r('sys.color.comp_background_list_card'))
            }
          }
          .alignItems(HorizontalAlign.Start)
          .padding({ left: '4vp' })
        }
        .width('90vp')

        Blank()

        Button(this.isFollowed ? $r('app.string.followed') : $r('app.string.follow'))
          .padding({
            left: 0,
            right: 0
          })
          .fontSize(12)
          .height('32vp')
          .width('48vp')
          .onClick(() => {
            this.isFollowed = !this.isFollowed;
          })
          .backgroundColor(this.isFollowed ? Color.Gray : '#0A59F7')
      }
      .padding({
        left: '4vp',
        right: '4vp'
      })
      .width('160vp')
      .height('40vp')
      .backgroundColor($r('sys.color.mask_fourth'))
      .borderRadius(20)

      Blank()

      Image($r('app.media.close_button'))
        .id('close')
        .width('40vp')
        .height('40vp')
        .onClick(() => {
          this.pageStack.pop();
        })
    }
    .width('100%')
    .padding({
      top: '16vp',
      bottom: '16vp',
      left: '16vp',
      right: '16vp'
    })
    .position({ top: '32vp' })
  }

  @Builder
  BottomBar() {
    Image($r('app.media.menu_icon_share'))
      .width('28vp')
      .height('28vp')
      .objectFit(ImageFit.Contain)
      .position({
        bottom: 32,
        right: 16
      })
      .onClick(() => {
        try {
          this.getUIContext()
            .getPromptAction()
            .showToast({ message: $r('app.string.feature_not_supported'), duration: 200 });
        } catch (error) {
          Logger.error(TAG, `ShowToast failed, errCode = ${error.code}, errMessage = ${error.message}.`);
        }
      })

    Image($r('app.media.menu_icon_like'))
      .width('28vp')
      .height('28vp')
      .objectFit(ImageFit.Contain)
      .position({
        bottom: 32,
        right: 64
      })
      .fillColor(this.isLiked ? Color.Red : Color.White)
      .onClick(() => {
        this.isLiked = !this.isLiked;
      })
  }

  @Builder
  CommentList() {
    Column() {
      List({ space: 6, initialIndex: 0, scroller: this.scroller }) {
        ForEach(this.liveList, (item: CommentDataModel) => {
          ListItem() {
            Text() {
              Span(item.name)
                .fontSize('12fp')
                .fontColor($r('app.color.comment_color'));
              Span(':')
                .fontSize('12fp')
                .fontColor($r('app.color.comment_color'));
              Span(item.comment)
                .fontSize('12fp')
                .fontColor($r('app.color.comment_color'));
            }
            .padding({
              left: '10vp',
              top: '5vp',
              right: '10vp',
              bottom: '5vp'
            })
            .borderRadius(18)
            .backgroundColor($r("app.color.comment_background_color"));
          }
        }, (item: CommentDataModel) => JSON.stringify(item));
      }
      .width('100%')
      .height('100%');
    }
    .alignItems(HorizontalAlign.Start)
    .width('60%')
    .height('252vp')
    .margin({ bottom: '6vp' })
    .position({
      bottom: '32vp',
      left: '16vp'
    });
  }

  build() {
    RelativeContainer() {
      this.TopBar();
      this.BottomBar();
      this.CommentList();
    }
    .width('100%')
    .height('100%');
  }
}