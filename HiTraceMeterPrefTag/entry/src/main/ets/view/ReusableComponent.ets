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
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';
import CommonConstants from '../common/CommonConstants'
import { AttributeUpdater } from '@kit.ArkUI';

/**
 * Defines a modifier which can update attributes to native side.
 */
class MyTextUpdater extends AttributeUpdater<TextAttribute> {
  private color: string | number | Resource | Color = '';

  constructor(color: string | number | Resource | Color) {
    super();
    this.color = color;
  }

  /**
   * Defines a function for initialization.
   */
  initializeModifier(instance: TextAttribute): void {
    instance.fontColor(this.color);
  }
}

@Reusable
@Component
export struct ReusableComponent {
  @Prop text: string;
  color: string | number | Resource | Color = '';
  textUpdater: MyTextUpdater | null = null;

  aboutToAppear(): void {
    this.textUpdater = new MyTextUpdater(this.color);
  }

  aboutToReuse(params: Record<string, Object>): void {
    // HiTraceMeter start tagging
    hiTraceMeter.startTrace(CommonConstants.LIFECYCLE_TASK_NAME, CommonConstants.LIFECYCLE_TASK_ID);
    this.color = params.color as string;
    this.textUpdater?.attribute?.fontColor(this.color);
    // HiTraceMeter finish tagging
    hiTraceMeter.finishTrace(CommonConstants.LIFECYCLE_TASK_NAME, CommonConstants.LIFECYCLE_TASK_ID);
  }

  build() {
    Column() {
      Text(this.text)
        .fontSize(18)
        .textAlign(TextAlign.Center)
        .fontWeight(CommonConstants.TEXT_FONT_WEIGHT)
        .lineHeight(24)
        .fontColor(Color.Black)
        .opacity(CommonConstants.TEXT_OPACITY)
      Column() {
        Text(CommonConstants.CONTENT)
          .attributeModifier(this.textUpdater)
          .textAlign(TextAlign.Start)
          .fontSize(CommonConstants.TEXT_FONT_SIZE)
          .fontWeight(CommonConstants.TEXT_FONT_WEIGHT)
          .lineHeight(21)
      }
      .borderRadius(16)
      .margin({ top: 14 })
      .padding({
        left: 16,
        right: 16,
        top: 8,
        bottom: 8
      })
      .backgroundColor(Color.White)
    }
    .alignItems(HorizontalAlign.Start)
    .margin({
      left: 16,
      right: 16
    })
  }
}