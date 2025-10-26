/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { PlayerLayoutSize } from '@hadss/swipeplayer';
import { CommonConstant } from '../constant/CommonConstant';
import { LiveCommentsData, LiveCommentsModel, CommentsData } from '../model/CommonModel';
import { CommentDetails } from './CommentDetails';

@Component
export struct Comments {
  @State firstIndex: number = 0;
  @State playerLayoutSize: PlayerLayoutSize = null!;
  @Prop dialogComponentData: CommentsData = null!;
  @StorageLink('displayWidth') displayWidth: number = 0;
  @StorageLink('isTabShow') isTabShow: boolean = true;
  @StorageLink('verticalScreenDataIsShow') verticalScreenDataIsShow: boolean = false;
  private closeDialog: () => void = null!;
  private commentListData: LiveCommentsData[] = new LiveCommentsModel().getLiveCommentsList();

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column }) {
        // At the top of the comment section
        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Text(CommonConstant.getLiveCommentsText(this.getUIContext()))
            .fontSize(CommonConstant.LIVE_COMMENTS_TEXT_FONTSIZE)
            .fontWeight(CommonConstant.CUSTOM_FONT_WEIGHT);
          Image(CommonConstant.IMAGE_CLOSE)
            .width(CommonConstant.LIVE_COMMENTS_CLOSE_WIDTH)
            .id('closeCommentButton')
            .onClick(() => {
              this.closeDialog();
              this.getUIContext().animateTo({ duration: 350 }, () => {
                this.isTabShow = true;
                this.verticalScreenDataIsShow = true;
              });
            });
        }
        .margin({
          top: CommonConstant.LIVE_COMMENTS_TEXT_MARGIN,
          bottom: CommonConstant.LIVE_COMMENTS_TEXT_MARGIN
        })
        .width(CommonConstant.FULL_PERCENT_WIDTH)
        .height(CommonConstant.TEN_PERCENT_HEIGHT)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);

        // Comment section content
        List({ space: CommonConstant.LIVE_COMMENTS_LIST_SPACE }) {
          ForEach(this.commentListData, (item: LiveCommentsData, index: number) => {
            CommentDetails({ liveCommentsData: item, firstIndex: this.firstIndex, index: index });
          }, (item: LiveCommentsData) => JSON.stringify(item));
        }
        .width(CommonConstant.FULL_PERCENT_WIDTH)
        .height(CommonConstant.SEVENTY_FIVE_PERCENT_HEIGHT)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);

        // At the bottom of the comment section
        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
          TextInput({ placeholder: CommonConstant.getLiveCommentsTextInputPlaceholder(this.getUIContext()) })
            .backgroundColor(CommonConstant.SYSTEM_CUSTOM_BACKGROUND_COLOR)
            .width(CommonConstant.EIGHTY_PERCENT_WIDTH);
          Image(CommonConstant.LIVE_COMMENTS_BOTTOM_IMAGE)
            .width(CommonConstant.LIVE_COMMENTS_BOTTOM_IMAGE_WIDTH);
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .width(CommonConstant.FULL_PERCENT_WIDTH)
        .height(CommonConstant.TEN_PERCENT_HEIGHT);
      }
      .backgroundColor(CommonConstant.LIVE_COMMENTS_BACKGROUND_COLOR)
      .padding({
        left: CommonConstant.LIVE_COMMENTS_PADDING,
        right: CommonConstant.LIVE_COMMENTS_PADDING
      })
      .width(CommonConstant.FULL_PERCENT_WIDTH)
      .height(CommonConstant.SEVENTY_PERCENT_HEIGHT)
      .translate({ y: this.dialogComponentData.y })
      .borderRadius({
        topLeft: CommonConstant.FOLD_FAST_SPEED_CORNER_RADIUS[1],
        topRight: CommonConstant.FOLD_FAST_SPEED_CORNER_RADIUS[1],
      })
      .alignRules({
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
        left: { anchor: '__container__', align: HorizontalAlign.Start }
      });
    }
    .onClick(() => {
      hilog.info(0x0000, 'commentsClick', 'click');
    });
  }
}

