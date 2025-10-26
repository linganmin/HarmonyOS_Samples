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
* FAQ：如何实现弹窗动画和遮罩动画分开设置？
*/

// [Start Set_Dialog_Animation_And_Mask_Animation_Separately]
import { ComponentContent } from '@kit.ArkUI';

export interface SimpleDialogParams {
  title: string
  desc: string
  visible?: Visibility
}

@Builder
function SimpleDialogBuilder(params: SimpleDialogParams) {
  SimpleDialogUI({ params })
}

@Component
struct SimpleDialogUI {
  @Prop params: SimpleDialogParams | null = null;
  @State yOffset: number | string = '100%';
  @Prop visible: Visibility = Visibility.Visible;

  build() {
    Column() {
      Text(this.params?.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .fontColor(Color.Black)
        .margin({ bottom: 16 })
        .width('100%')
      Text(this.params?.desc)
        .fontSize(14)
        .lineHeight(22)
        .fontColor(Color.Gray)
        .margin({ bottom: 16 })
        .width('100%')
    }
    .borderRadius({ topLeft: 16, topRight: 16 })
    .backgroundColor(Color.White)
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .visibility(this.params?.visible)
    .padding(20)
    .transition(TransitionEffect.translate({ y: '100%' }).animation({ duration: 200 }))
  }
}

@Entry
@Component
struct SetDialogAnimationAndMaskAnimationSeparately {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          const param =
            { title: '标题标题标题', desc: '描述描述描述描述描述描述描述描述描述描述描述描述' } as SimpleDialogParams;
          const contentNode = new ComponentContent(this.getUIContext(), new WrappedBuilder(SimpleDialogBuilder), param);
          this.getUIContext().getPromptAction().openCustomDialog(contentNode, {
            autoCancel: true,
            maskColor: 'cc000000',
            maskRect: {
              x: 0,
              y: '-100%',
              width: '100%',
              height: '200%'
            },
            alignment: DialogAlignment.Bottom,
            transition: TransitionEffect.opacity(0).animation({ duration: 200 }),
            onWillDismiss: res => {
              contentNode.update({
                title: '标题标题标题',
                desc: '描述描述描述描述描述描述描述描述描述描述描述描述',
                visible: Visibility.Hidden
              });
              res.dismiss();
            }
          });
        })
    }
    .width('100%')
    .height('100%')
  }
}

// [End Set_Dialog_Animation_And_Mask_Animation_Separately]