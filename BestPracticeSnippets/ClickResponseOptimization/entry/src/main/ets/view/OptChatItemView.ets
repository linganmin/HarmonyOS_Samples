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

/**
 *  最佳实践：点击响应优化
 */
import ChatModel from '../model/ChatModel'
import router from '@ohos.router'

@Component
export struct OptChatItemView {
  @Prop itemData: ChatModel

  build() {
    RelativeContainer() {
      Badge({ value: "", style: { badgeSize: this.itemData.hasBadge ? 8 : 0, badgeColor: '#FA2A2D' } }) {
        // [Start image2]
        // Use the avatar in the list as a shared element, specifying the ID as sharedImage+this.itemData.id.
        Image(this.itemData.avatar)
          .height('40vp')
          .width('40vp')
          .borderRadius(8)
          .sharedTransition('sharedImage' + this.itemData.id, { duration: 500, curve: Curve.FastOutSlowIn, delay: 0 })
        // [End image2]
      }
      .id('head')
      .height('40vp')
      .width('40vp')
      .alignRules({
        center: { anchor: "__container__", align: VerticalAlign.Center },
        left: { anchor: "__container__", align: HorizontalAlign.Start }
      })
      .onClick(() => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/ProfilePage', params: { itemData: this.itemData } })
      })

      Text(this.itemData.name)
        .fontSize('16.0fp')
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontColor('# ff182431')
        .maxLines(1)
        .fontWeight(FontWeight.Medium)
        .padding({ left: '12vp' })
        .height(22)
        .alignRules({
          top: { anchor: 'head', align: VerticalAlign.Top },
          left: { anchor: 'head', align: HorizontalAlign.End }
        })
        .id('name')
      Text(this.itemData.time)
        .fontColor('# 66182431')
        .fontSize('12fp')
        .maxLines(1)
        .height(22)
        .alignRules({
          top: { anchor: 'head', align: VerticalAlign.Top },
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
        .id("time")

      Text() {
        Span(this.itemData.snippet.replace(new RegExp("/[\r\n]/g"), " "))
          .fontSize('14fp')
          .fontColor('#66182431')
      }
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .width('100%')
      .height(19)
      .margin({ top: '2vp' })
      .padding({ left: '12vp' })
      .alignRules({
        top: { anchor: 'name', align: VerticalAlign.Bottom },
        left: { anchor: 'head', align: HorizontalAlign.End }
      })
      .id('content')

      if (this.itemData.hasMute) {
        Image($r('app.media.ic_public_donotdisturb'))
          .width(14)
          .height(14)
          .fillColor('#86182431')
          .margin(2)
          .alignRules({
            top: { anchor: 'time', align: VerticalAlign.Bottom },
            right: { anchor: '__container__', align: HorizontalAlign.End }
          })
          .id('mute')
      }
    }
    .width('100%').height('100%')
  }
}