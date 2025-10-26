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

import { promptAction } from '@kit.ArkUI';
import { Logger } from './Logger';

/**
 * Dialog management class
 */
export class PromptActionManager {
  static ctx: UIContext;
  static contentNode: ComponentContent<Object>;
  static options: promptAction.BaseDialogOptions;

  static setCtx(ctx: UIContext) {
    PromptActionManager.ctx = ctx;
  }

  static setContentNode(contentNode: ComponentContent<Object>) {
    PromptActionManager.contentNode = contentNode;
  }

  static setOptions(options: promptAction.BaseDialogOptions) {
    PromptActionManager.options = options;
  }

  static openCustomDialog() {
    if (!PromptActionManager.contentNode) {
      return;
    }
    try {
      PromptActionManager.ctx.getPromptAction().openCustomDialog(
        PromptActionManager.contentNode,
        PromptActionManager.options
      )
    } catch (error) {
      Logger.error('openCustomDialog', `openCustomDialog failed, code is ${error.code}, message is ${error.message}`);
    }
  }

  static closeCustomDialog() {
    if (!PromptActionManager.contentNode) {
      return;
    }
    try {
      PromptActionManager.ctx.getPromptAction().closeCustomDialog(
        PromptActionManager.contentNode
      )
    } catch (error) {
      Logger.error('openCustomDialog', `openCustomDialog failed, code is ${error.code}, message is ${error.message}`);
    }
  }
}