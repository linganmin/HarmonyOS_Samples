/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import { mediaquery } from '@kit.ArkUI';
import { Callback } from '@kit.BasicServicesKit';
import { LiveInfoDataModel } from '../model/LiveDataModel';
import { LiveData } from '../mock/LiveData';

@Preview
@Component
export struct CommentPage {
  @State liveInfoData: Array<LiveInfoDataModel> = [];
  @State text: string = '';
  @State isPhone: boolean = false;
  scroller: Scroller = new Scroller();
  portraitFunc: Callback<mediaquery.MediaQueryResult> = (mediaQueryResult: mediaquery.MediaQueryResult): void => {
    this.onPortrait(mediaQueryResult);
  };
  listenerIsPhone = this.getUIContext().getMediaQuery().matchMediaSync('(orientation:landscape)');

  onPortrait(mediaQueryResult: mediaquery.MediaQueryResult) {
    this.isPhone = !mediaQueryResult.matches;
  }

  aboutToAppear() {
    this.listenerIsPhone.on('change', this.portraitFunc);

    LiveData.forEach((item) => {
      this.liveInfoData.push(new LiveInfoDataModel(item));
    });
  }

  build() {
    Column() {
      Column() {
        Blank()
      }
      .alignItems(HorizontalAlign.Start)
      .width('60%')
      .height('66%')

      // Bottom assembly.
      Row() {
        Image($r('app.media.live_shopping'))
          .width(52)
          .height(52)
        TextInput({ placeholder: $r('app.string.say_something'), text: this.text })
          .backgroundColor('rgba(0,0,0,0.20)')
          .placeholderColor('rgb(255,255,255)')
          .fontColor('rgb(255,255,255)')
          .enableKeyboardOnFocus(false)
          .padding({ left: 20 })
          .width('47.2%')
          .height(52)
          .borderRadius(26)
          .margin({ left: 16 })
          .onChange((value: string) => {
            this.text = value;
          })
        Image($r('app.media.givelike'))
          .width(52)
          .height(52)
          .margin({ left: '22%' })
      }
      .justifyContent(FlexAlign.Start)
      .margin({ top: 10 })
    }
    .alignItems(HorizontalAlign.Start)
    .width('95%')
    .height('28%')
  }
}
