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

/*
* FAQ:进入全屏模式后隐藏状态栏，退出全屏模式如何显示状态栏？
*/

// [Start full_screen_status_bar]
import { window } from '@kit.ArkUI';


@Entry
@Component
struct GridImage {
  @State message: string = 'Hello World';
  @State isVisible: boolean = true;
  @State isVisibleButton: boolean = true;
  data: number[] = [];
  windowClass = AppStorage.get<window.Window>('windowClass') as window.Window;


  aboutToAppear(): void {
    for (let i = 0; i < 40; i++) {
      this.data.push(i);
    }
  }


  build() {
    Stack() {
      Grid() {
        ForEach(this.data, (item: number, index: number) => {
          GridItem() {
            Image($r('app.media.startIcon'))
              .width('100%')
              .objectFit(ImageFit.Cover)
              .onClick(() => {
                let isLayoutFullScreen = true;
                this.windowClass.setWindowLayoutFullScreen(isLayoutFullScreen);
                this.windowClass.setSpecificSystemBarEnabled('status', false);
                this.windowClass.setSpecificSystemBarEnabled('navigationIndicator', false);
                this.isVisible = !this.isVisible;
              })
          }
          .aspectRatio(1)
        }, (item: number, index: number) => JSON.stringify(item) + index)
      }
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(2)
      .columnsGap(2)
      .height('100%')
      .width('100%')


      Image($r('app.media.startIcon'))
        .objectFit(ImageFit.Contain)
        .width('100%')
        .visibility(this.isVisible ? Visibility.None : Visibility.Visible)
        .onClick(() => {
          let isLayoutFullScreen = false;
          this.windowClass.setSpecificSystemBarEnabled('status', true);
          this.windowClass.setSpecificSystemBarEnabled('navigationIndicator', true);
          this.windowClass.setWindowLayoutFullScreen(isLayoutFullScreen);
          this.isVisible = !this.isVisible;
        })
    }
  }
}
// [End full_screen_status_bar]