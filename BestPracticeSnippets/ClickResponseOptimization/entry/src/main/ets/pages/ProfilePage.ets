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
import Constants from '../common/constants/WorldConstants';
import ChatModel from '../model/ChatModel';
import { LoadingView } from '../view/LoadingView';
import router from '@ohos.router';

@Entry
@Component
export struct ProfilePage {
  itemData: ChatModel = (this.getUIContext().getRouter().getParams() as Record<string, ChatModel>)['itemData'];
  @State showLoading: boolean = true

  // Page B transition animation settings
  pageTransition() {
    PageTransitionEnter({ type: RouteType.None, duration: 400 })
      .slide(SlideEffect.Right)
    PageTransitionExit({ type: RouteType.None, duration: 400 })
      .slide(SlideEffect.Right)
  }

  onPageShow() {
    setTimeout(() => {
      this.showLoading = false
    }, 2000)
  }

  build() {
    Column() {
      Stack() {
        Column() {
          Image($r('app.media.user_background_image'))
            .width(Constants.FULL_SCREEN)
            .height(220)
            .objectFit(ImageFit.Cover)
        }.width(Constants.FULL_SCREEN).aspectRatio(3 / 2)

        Column() {
          Row({ space: Constants.MIDDLE_SPACE }) {
            // [Start image3]
            // The shared elements on the personal page must have the same ID as the previous page.
            Image(this.itemData.avatar)
              .size({
                width: $r('app.float.user_image_size'),
                height: $r('app.float.user_image_size')
              })// .borderRadius($r('app.float.user_image_border_radius'))
              .borderRadius(8)
              .margin({ bottom: $r('app.float.user_image_padding'), top: $r('app.float.user_image_padding') })
              .sharedTransition('sharedImage' + this.itemData.id,
                { duration: 500, curve: Curve.FastOutSlowIn, delay: 0 })
            // [End image3]
            Text(this.itemData.name)
              .fontColor($r('app.color.hmos_color_white'))
              .fontSize($r('app.float.user_account_font_size'))
              .padding({ bottom: $r('app.float.login_account_padding_bottom') })
          }
          .width(Constants.FULL_SCREEN)
          .justifyContent(FlexAlign.Start)
          .margin({ bottom: '0' })

          Text('欢迎来到HarmonyOS世界')
            .width(Constants.FULL_SCREEN)
            .fontSize($r('app.float.login_information_font_size'))
            .fontColor($r('app.color.hmos_color_white'))
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ left: $r('app.float.login_account_padding_left') })
        .width(Constants.FULL_SCREEN)
        .height($r('app.float.user_background_height'))
      }

      if (this.showLoading) {
        LoadingView()
      } else {
        Image($r('app.media.screen_list_img'))
          .width(Constants.FULL_SCREEN)
          .height('68%')
          .objectFit(ImageFit.Fill)
      }
    }
  }
}