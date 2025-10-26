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
* FAQ:如何控制CustomDialog显示层级
*/

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

// [Start custom_dialog_display_level]
@Component
struct PrivacyDetailPage {
  @State message: string = 'Hello World';

  build() {
    NavDestination() {
      Row() {
        Column() {
          Text(this.message)
            .fontSize(50)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
      }
      .height('100%')
    }
    .onBackPressed(() => {
      this.getUIContext().getPromptAction().showToast({ message: '123' });
      return false;
    })
  }
}

@Entry
@Component
struct CustomDialogDisplayLevel {
  // Used for navigation stack management
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @State textValue: string = 'Input';
  // Visible and hidden control is set to not occupied
  @State visible: Visibility = Visibility.None;

  @Builder
  pageMap(name: string) {
    if (name === 'pageOne') {
      PrivacyDetailPage()
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Stack() {
          Row() {
            Column() {
              Text('I am the first page')
                .fontSize(30)
                .fontWeight(FontWeight.Bold)
              Button('Button')
                .onClick(() => {
                  console.info('hit me!');
                  if (this.visible === Visibility.Visible) {
                    this.visible = Visibility.None;
                  } else {
                    this.visible = Visibility.Visible;
                  }
                })
                .backgroundColor(0x777474)
                .fontColor(0x000000)
            }
            .height('100%')
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Center)
          }
          .height('100%')
          .backgroundColor('#FFF')

          Text('')
            .onClick(() => {
              if (this.visible === Visibility.Visible) {
                this.visible = Visibility.None;
              } else {
                this.visible = Visibility.Visible;
              }
            })
            .width('100%')
            .height('100%')
            // set opacity
            .opacity(0.5)
            .backgroundColor(Color.Black)
            .visibility(this.visible)
          Column() {
            GridRow({
              columns: {
                xs: 1,
                sm: 4,
                md: 8,
                lg: 12
              },
              breakpoints: {
                value: ['400vp', '600vp', '800vp'],
                reference: BreakpointsReference.WindowSize
              },
            }) {
              GridCol({
                span: {
                  xs: 1,
                  sm: 2,
                  md: 4,
                  lg: 8
                },
                offset: {
                  xs: 0,
                  sm: 1,
                  md: 2,
                  lg: 2
                }
              }) {
                Column() {
                  Text('Privacy')
                    .fontSize(20)
                    .margin({
                      top: 10,
                      bottom: 10
                    })
                  Text('Do you want to jump to the privacy details page?')
                    .fontSize(16)
                    .margin({ bottom: 10 })
                  Flex({ justifyContent: FlexAlign.SpaceAround }) {
                    Button('Cancel')
                      .onClick(() => {
                        if (this.visible === Visibility.Visible) {
                          this.visible = Visibility.None;
                        } else {
                          this.visible = Visibility.Visible;
                        }
                      })
                      .backgroundColor(0xffffff)
                      .fontColor(Color.Black)
                    Button('OK')
                      .onClick(() => {
                        try {
                          this.pageInfos.pushPath({ name: 'pageOne' });
                        } catch (error) {
                          let err = error as BusinessError;
                          hilog.error(0x00, 'PrivacyDetailPage', `error code: ${err.code},message:${err.message}`);
                        }
                      })
                      .backgroundColor(0xffffff)
                      .fontColor(Color.Red)
                  }
                  .margin({ bottom: 10 })
                }
                .backgroundColor(0xffffff)
                .visibility(this.visible)
                .clip(true)
                .borderRadius(20)
              }
            }
          }
          // set dialog width
          .width('100%')
        }
      }
      .width('100%')
      .margin({ top: 5 })
    }
    .navDestination(this.pageMap)
  }
}

// [End custom_dialog_display_level]