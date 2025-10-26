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
// components/MultiSelectDialog.ets
import { SettingPopupOptionItem } from '../model/SettingPopupOptionItem';

@Preview
@CustomDialog
export struct SettingPopupDialog {
  controller: CustomDialogController;
  @State title: string = 'Setting';
  @State options: SettingPopupOptionItem[] = [];

  build() {
    Column() {
      // title
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Center)
        .width("100%")
        .height("56vp")
        .textAlign(TextAlign.Center)
        .padding({
          left: 24,
          top: 15,
          right: 24,
          bottom: 15
        })
        .borderRadius({
          topLeft: 16,
          topRight: 16,
          bottomRight: 0,
          bottomLeft: 0
        })


      // Option list
      List() {
        ForEach(this.options, (item: SettingPopupOptionItem, index: number) => {
          ListItem() {
            Column() {
              Row() {
                Column() {
                  Text(item.label)
                    .fontSize('16fp')
                    .fontWeight(500)
                    .align(Alignment.Center)
                }
                .width(192)
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Center)

                Toggle({ type: ToggleType.Switch, isOn: !!item.checked })
                  .selectedColor($r('sys.color.brand'))
                  .switchPointColor($r('sys.color.comp_background_list_card'))
                  .onChange((isOn: boolean) => {
                    item.checked = isOn;
                    item.handler(item.checked);
                  })
                  .padding({
                    right: 0,
                    bottom: 0,
                    top: 0
                  })
                  .margin({
                    right: 0,
                    top: 0,
                    bottom: 0
                  })
              }
              .padding({
                left: '12vp',
                right: '12vp',
                top: '0vp',
                bottom: '0vp'
              })
              .width('100%')
              .height("48vp")
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Center)

              if (index != this.options.length - 1) {
                Divider()
                  .strokeWidth(1)
                  .color('#CCC')
                  .width('100%')
                  .padding({
                    left: '12vp',
                    right: '12vp'
                  })

              }
            }

          }
          .width("100%")
          .padding({
            left: '15vp',
            right: '9vp',
            top: '0vp',
            bottom: '0vp'
          })
        })
      }
      .alignListItem(ListItemAlign.Center)
      .width("100%");

      Row() {
        Text($r('app.string.setting_ok'))
          .fontColor("#0A59F7")
          .fontFamily("HarmonyHeiTi")
          .fontWeight(500)
          .lineHeight(1)
          .width('140vp')
          .height('40vp')
          .onClick(() => {
            this.controller.close();
          })
          .padding({
            left: 16,
            top: 9,
            right: 16,
            bottom: 9,
          })
          .textAlign(TextAlign.Center)

      }
      .width("100%")
      .padding({
        left: 16,
        top: 0,
        right: 16,
        bottom: 16
      })
      .margin({ top: 20 })
      .justifyContent(FlexAlign.Center)
    }
    .alignItems(HorizontalAlign.Center);
  }
}