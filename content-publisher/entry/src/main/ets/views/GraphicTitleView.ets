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

import { CommonConstants } from '../constants/CommonConstants';
import { GraphicTitle, GraphicTitleGroup } from '../models/CommonModel';

@Component
export struct GraphicTitleView {
  @Consume('titleInfo') titleInfo: GraphicTitle;
  private graphicTitleGroups: GraphicTitleGroup[] = CommonConstants.GRAPHIC_TITLE_GROUPS;
  public onSelect: () => void = () => {};

  build() {
    List() {
      ForEach(this.graphicTitleGroups, (group: GraphicTitleGroup) => {
        ListItem() {
          Column() {
            Text(group.title)
              .fontSize(14)
              .fontColor('#606162')
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .padding({
                left: 16,
                top: 13,
                bottom: 8
              })
            Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
              ForEach(group.graphicTitleList, (item: GraphicTitle) => {
                Text() {
                  Span(item.titlePicUrl)
                  Span(item.title)
                }
                .onClick(() => {
                  this.titleInfo = item;
                  this.onSelect();
                })
                .borderRadius(6)
                .backgroundColor($r('sys.color.background_secondary'))
                .padding({
                  top: 12,
                  right: 6,
                  bottom: 12,
                  left: 6
                })
                .margin({
                  top: 8,
                  bottom: 8,
                  left: 16
                })
              }, (item: GraphicTitle, index: number) => JSON.stringify(item) + index)
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
      }, (group: GraphicTitleGroup, index: number) => group.title.toString() + index)
    }
    .width('100%')
    .scrollBar(BarState.Off)
  }
}