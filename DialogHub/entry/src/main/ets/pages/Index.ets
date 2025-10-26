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
/**
 * 最佳实践：基于StateStore的全局状态管理开发实践
 */
import { DialogHub } from '@hadss/dialoghub';
import { TextToastBuilder } from '../component/TextToastBuilder';
import CommonConstant from '../utils/CommonConstant';

@Entry
@Component
struct Index {
  pageInfos: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    // [Start get_ui_context]
    DialogHub.init(this.getUIContext());
    // [End get_ui_context]
    DialogHub.openLog('DEBUG');
    // [Start wrap_create]
    DialogHub.createCustomTemplate(CommonConstant.CUSTOM_TEMPLATE_SIMPLE)
      .setContent(wrapBuilder(TextToastBuilder))
      .setStyle({ backgroundColor: Color.White })
      .setConfig({ dialogBehavior: { passThroughGesture: true, isModal: false } })
        // [End wrap_create]
      .register();
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Button($r('app.string.CommonDialogExamples'), { stateEffect: true, type: ButtonType.Capsule })
          .superFancyButton()
          .onClick(() => {
            this.pageInfos.pushPath({ name: CommonConstant.COMMON_ACTION_PATH });
          })
        Button($r('app.string.OperableDialogExamples'), { stateEffect: true, type: ButtonType.Capsule })
          .superFancyButton()
          .onClick(() => {
            this.pageInfos.pushPath({ name: CommonConstant.OPERABLE_ACTION_PATH });
          })
        Button($r('app.string.ReusableDialogExamples'), { stateEffect: true, type: ButtonType.Capsule })
          .superFancyButton()
          .onClick(() => {
            this.pageInfos.pushPath({ name: CommonConstant.REUSE_ACTION_PATH });
          })
        Button($r('app.string.MultipleDialogExamples'), { stateEffect: true, type: ButtonType.Capsule })
          .superFancyButton()
          .onClick(() => {
            this.pageInfos.pushPath({ name: CommonConstant.MULTI_ACTION_PATH });
          })
      }
      .height(CommonConstant.FULL_LENGTH)
      .justifyContent(FlexAlign.End)
      .margin({ left: $r('app.float.index_body_margin'), right: $r('app.float.index_body_margin') })
      .padding({ bottom: $r('app.float.index_body_padding') })
    }
    .padding({ top: $r('app.float.index_page_padding') })
    .title($r('app.string.DialogHubDialogExamples'))
    .backgroundColor($r('app.color.index_page_bg_color'))
    .mode(NavigationMode.Stack)
  }
}

@Extend(Button)
function superFancyButton() {
  .width(CommonConstant.FULL_LENGTH)
  .height($r('app.float.index_action_height'))
  .margin({ bottom: $r('app.float.index_action_margin') })
  .fontSize($r('app.float.font_size_medium'))
  .fontWeight(FontWeight.Medium)
  .backgroundColor($r('app.color.base_blue'))
}