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
export struct SavePicker {
  controller?: CustomDialogController;
  cancel: () => void = () => {
  };
  confirm: () => void = () => {
  };

  build() {
    Column() {
      Text($r('app.string.save_image'))
        .textAlign(TextAlign.Center)
        .fontSize(18)
        .fontColor($r('sys.color.black'))
        .fontSize(20)
        .height(56)
        .fontWeight(FontWeight.Bold)

      Text($r('app.string.confirm_save'))
        .textAlign(TextAlign.Center)
        .fontSize(16)
        .fontColor('rgba(0, 0, 0, 0.9)')
        .lineHeight('21vp')
        .fontWeight(500)

      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
        Button($r('app.string.cancel'),
          { buttonStyle: ButtonStyleMode.TEXTUAL, role: ButtonRole.NORMAL, stateEffect: false })
          .fontColor('#0A59F7')
          .fontSize(16)
          .fontWeight(500)
          .onClick(() => {
            this.cancel();
          })
        Divider()
          .vertical(true)
          .height(22)
          .color($r('sys.color.mask_fourth'))
          .opacity(0.6)
          .margin({ left: 50, right: 50 })
        Button($r('app.string.save'),
          { buttonStyle: ButtonStyleMode.TEXTUAL, role: ButtonRole.NORMAL, stateEffect: false })
          .fontSize(16)
          .fontColor('#0A59F7')
          .fontWeight(500)
          .onClick(() => {
            this.confirm();
          })

      }
      .height('40vp')
      .margin({ top: '8vp', bottom: 16 })
    }
    .backgroundColor('#0C182431')
    .borderRadius($r('sys.float.slider_inset_block_hot_region_size'))
    .padding({ left: 24, right: 24 })
  }
}