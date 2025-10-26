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

import { BusinessError } from '@kit.BasicServicesKit';
import { ComponentContent, promptAction, UIContext } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class PromptActionClass {
  static ctx: UIContext;
  static contentNode: ComponentContent<Object>;
  static options: promptAction.BaseDialogOptions;


  static setContext(context: UIContext) {
    PromptActionClass.ctx = context;
  }


  static setContentNode(node: ComponentContent<Object>) {
    PromptActionClass.contentNode = node;
  }


  static setOptions(options: promptAction.BaseDialogOptions) {
    PromptActionClass.options = options;
  }


  static openDialog() {
    if (PromptActionClass.contentNode !== null) {
      PromptActionClass.ctx.getPromptAction().openCustomDialog(PromptActionClass.contentNode, PromptActionClass.options)
        .then(() => {
          hilog.info(0xFF00, 'TAG', 'OpenCustomDialog complete');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          hilog.info(0xFF00, 'TAG', `OpenCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }


  static closeDialog(contentNode: ComponentContent<Object>) {
    if (PromptActionClass.contentNode !== null) {
      PromptActionClass.ctx.getPromptAction().closeCustomDialog(contentNode)
        .then(() => {
          hilog.info(0xFF00, 'TAG', 'CloseCustomDialog complete');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          hilog.info(0xFF00, 'TAG', `CloseCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }


  static updateDialog(options: promptAction.BaseDialogOptions) {
    if (PromptActionClass.contentNode !== null) {
      PromptActionClass.ctx.getPromptAction().updateCustomDialog(PromptActionClass.contentNode, options)
        .then(() => {
          hilog.info(0xFF00, 'TAG', 'UpdateCustomDialog complete');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          hilog.info(0xFF00, 'TAG', `UpdateCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }
}