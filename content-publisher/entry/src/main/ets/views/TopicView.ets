/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { CommonConstants } from '../constants/CommonConstants';
import { TopicInfo, TopicGroup } from '../models/CommonModel';
import { Context } from '@kit.AbilityKit';
import { getResourceString } from '../utils/CommonUtil';

@Component
export struct TopicView {
  private context: Context = this.getUIContext().getHostContext()!;
  @Consume topicInfo: TopicInfo;
  private topicGroupList: TopicGroup[] = CommonConstants.TOPIC_GROUP_LIST;
  public onSelect: () => void = () => {};

  @Builder
  topicItem(item: TopicInfo) {
    Row() {
      Image($r('app.media.ic_topic_pop'))
        .width(22)
        .height(22)
        .margin({ right: 8 })
      Text(getResourceString(item.title, this.context) + item.topicId)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
      Blank()
      Text(item.viewCount + getResourceString($r('app.string.reading'), this.context))
        .fontSize(14)
        .fontColor('#58595A')
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .height(40)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.topicInfo = item;
      this.onSelect();
    })
  }

  build() {
    List() {
      ForEach(this.topicGroupList, (group: TopicGroup) => {
        ListItem() {
          Column() {
            Text(group.title)
              .fontColor('#585A5C')
              .fontSize(14)
              .width('100%')
              .height(40)
            ForEach(group.topicList, (topic: TopicInfo) => {
              this.topicItem(topic)
            }, (topic: TopicInfo) => group.groupId + topic.topicId)
          }
          .width('100%')
        }
      }, (group: TopicGroup) => group.groupId)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .padding({
      right: 16,
      left: 16
    })
  }
}