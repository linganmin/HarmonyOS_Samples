/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@CustomDialog
@Component
export struct MyCustomDialog {
  controller?: CustomDialogController;
  cancel: () => void = () => {
  };
  confirm: () => void = () => {
  };

  build() {
    Column() {
      Text($r('app.string.save_crop'))
        .textAlign(TextAlign.Center)
        .fontSize('16vp')
        .fontColor('rgba(0, 0, 0, 0.9)')
        .lineHeight('21vp')

      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
        Button($r('app.string.cancel'), { buttonStyle: ButtonStyleMode.EMPHASIZED, role: ButtonRole.NORMAL })
          .flexGrow(1)
          .backgroundColor(Color.Transparent)
          .fontColor('#0A59F7')
          .fontSize('16vp')
          .fontWeight(500)
          .onClick(() => {
            this.cancel();
          })
        Divider()
          .vertical(true)
          .strokeWidth('0.5vp')
          .height(24)
          .color('rgba(0, 0, 0, 0.05)')
          .margin({ left: 4, right: 4 })
        Button($r('app.string.confirm'), { buttonStyle: ButtonStyleMode.EMPHASIZED, role: ButtonRole.NORMAL })
          .flexGrow(1)
          .backgroundColor(Color.Transparent)
          .fontColor('#0A59F7')
          .fontSize('16vp')
          .fontWeight(500)
          .onClick(() => {
            this.confirm();
          })
      }
      .height('40vp')
      .margin({ top: '8vp' })
    }
    .width('328vp')
    .padding($r('sys.float.account_page_padding'))
    .borderRadius($r('sys.float.slider_inset_block_hot_region_size'))
    .backgroundColor(Color.White)
  }
}