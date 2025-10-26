/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { systemShare } from '@kit.ShareKit';
import CreateRecord from '../utils/CreateRecord';
import PostersScenario from '../scenario/PostersScenario';
import ImageScenario from '../scenario/ImageScenario';
import VideoScenario from '../scenario/VideoScenario';
import TextScenario from '../scenario/TextScenario';
import AppLinkingScenario from '../scenario/AppLinkingScenario';
import LinkScenario from '../scenario/LinkScenario';
import ZipScenario from '../scenario/ZipScenario';

@Component
export default struct UTDDemo {
  @Consume('pageStack') pageStack: NavPathStack;

  @State SelectOption: SelectOption[] = CreateRecord.utdMap.map((item) => {
    return { value: item.utd } as SelectOption;
  })

  @State text: ResourceStr = this.SelectOption[0].value;
  @State index: number = 0;

  @State records: systemShare.SharedRecord[] = [];

  build() {
    Scroll() {
      Column() {
        Row() {
          Text('自定义分享数据类型')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)

          Button('体验')
            .onClick(() => {
              this.pageStack.pushPathByName("FunctionExample", null);
            })
        }
        .width('100%')
        .margin({ top: 12 })
        .padding({ left: 20, right: 20 })
        .justifyContent(FlexAlign.SpaceBetween)


        Row() {
          Text('以下为常见分享数据类型示例,仅供参考.')
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .margin({ top: 20})
        .padding({ left: 20, right: 20 })
        .justifyContent(FlexAlign.Start)

        AppLinkingScenario()
        LinkScenario()
        ImageScenario()
        VideoScenario()
        TextScenario()
        PostersScenario()
        ZipScenario()
      }
      .width('100%')
      .constraintSize({ minHeight: '100%' })
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .height('100%')
  }
}