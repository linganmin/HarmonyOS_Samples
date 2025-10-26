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

import { Comment, CommentData } from '../model/CommentModel';
import { CommentView } from '../view/CommentItemView';
import { CommentInputDialog } from '../view/CommentInputDialog';
import { mockData } from '../model/MockCommentData';

const ID_ROW_PUBLISH: string = "id_row_publish";
const ID_TEXT_EMPTY: string = "id_text_empty";
const ID_LIST: string = "id_list";
const ID_TEXT_TITLE: string = "id_text_title";
const ID_IMAGE: string = "id_image";

@Entry
@Component
struct ImageCommentView {
  @State commentList: CommentData = new CommentData();
  @State textInComment: string = "";
  @State imageInComment: string[] = [];
  commentCount: number = 0;

  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CommentInputDialog({
      textInComment: $textInComment,
      imagesInComment: $imageInComment,
      publish: () => this.publishComment()
    }),
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    offset: {
      dx: $r('app.integer.dialog_offset_x'),
      dy: $r('app.integer.dialog_offset_y')
    }
  });

  aboutToAppear(): void {
    this.commentList = mockData();
    this.commentCount = this.commentList.totalCount();
  }

  aboutToDisappear() {
    this.dialogController = null;
  }

  publishComment(): void {
    const comment: Comment = new Comment("Kevin", this.textInComment, $r('app.media.icon'), this.imageInComment, this.getCurrentDate());
    this.commentList.addDataFirst(comment);
  }

  getCurrentDate(): string {
    const date: Date = new Date();
    return `${date.getFullYear()}-${date.getMonth()}-${date.getDay()} ${date.getHours()}:${date.getMinutes()}`;
  }

  build() {
    RelativeContainer() {
      Image($r('app.media.launch_advert'))
        .height($r('app.string.percent_30'))
        .alignRules({
          top: { anchor: "__container__", align: VerticalAlign.Top },
          left: { anchor: "__container__", align: HorizontalAlign.Start },
          right: { anchor: "__container__", align: HorizontalAlign.End }
        })
        .id(ID_IMAGE)
      Text($r('app.string.hot_comment'))
        .height($r('app.integer.text_hot_comment_height'))
        .width($r('app.string.percent_100'))
        .padding({
          left: $r('app.integer.text_hot_comment_padding_left')
        })
        .border({
          width: {
            bottom: $r('app.integer.text_hot_comment_border_width_bottom')
          },
          color: {
            bottom: $r('app.color.color_divider')
          }
        })
        .alignRules({
          top: { anchor: ID_IMAGE, align: VerticalAlign.Bottom },
          left: { anchor: "__container__", align: HorizontalAlign.Start },
          right: { anchor: "__container__", align: HorizontalAlign.End }
        })
        .id(ID_TEXT_TITLE)

      if (this.commentCount > 0) {
        List() {
          LazyForEach(this.commentList, (comment: Comment) => {
            ListItem() {
              CommentView({ comment: comment })
            }
          }, (item: Comment) => JSON.stringify(item))
        }
        .scrollBar(BarState.Off)
        .width($r('app.string.percent_100'))
        .margin({
          bottom: $r('app.integer.list_comment_margin_bottom')
        })
        .alignRules({
          top: { anchor: ID_TEXT_TITLE, align: VerticalAlign.Bottom },
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
          left: { anchor: "__container__", align: HorizontalAlign.Start },
          right: { anchor: "__container__", align: HorizontalAlign.End }
        })
        .id(ID_LIST)
      } else {
        Text($r('app.string.no_comment'))
          .textAlign(TextAlign.Center)
          .width($r('app.string.percent_100'))
          .margin({
            bottom: $r('app.integer.text_no_comment_margin_bottom')
          })
          .alignRules({
            top: { anchor: ID_TEXT_TITLE, align: VerticalAlign.Bottom },
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
            left: { anchor: "__container__", align: HorizontalAlign.Start },
            right: { anchor: "__container__", align: HorizontalAlign.End }
          })
          .id(ID_TEXT_EMPTY)
      }

      Row() {
        Text($r('app.string.text_input_hint'))
          .borderRadius($r('app.integer.text_input_hint_border_radius'))
          .height($r('app.integer.text_input_hint_height'))
          .width($r('app.string.percent_95'))
          .padding({
            left: $r('app.integer.text_input_hint_padding_left')
          })
          .backgroundColor($r('app.color.color_comment_text_background'))
          .onClick(() => {
            if (this.dialogController !== null) {
              this.dialogController.open();
            }
          })
          .border({
            width: $r('app.integer.text_input_hint_border_width'),
            color: $r('app.color.color_comment_text_border')
          })
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .height($r('app.integer.row_input_hint_height'))
      .width($r('app.string.percent_100'))
      .border({
        width: {
          top: $r('app.integer.row_input_hint_border_width_top')
        },
        color: {
          top: $r('app.color.color_divider')
        }
      })
      .alignRules({
        bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
        left: { anchor: "__container__", align: HorizontalAlign.Start },
        right: { anchor: "__container__", align: HorizontalAlign.End }
      })
      .id(ID_ROW_PUBLISH)

    }
    .width($r('app.string.percent_100'))
    .height($r('app.string.percent_100'))
  }
}
