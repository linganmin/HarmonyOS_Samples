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
import { AnimationType, DialogHub, InfToast } from '@hadss/dialoghub';
import { TextToastBuilder, TextToastParams } from '../../component/TextToastBuilder';
import CommonConstant from '../../utils/CommonConstant';

// [Start toast]
DialogHub.getToast()
// [End toast]

// [Start get_toast]
DialogHub.getToast()
  .setContent(wrapBuilder(TextToastBuilder), new TextToastParams(CommonConstant.TOAST_TITLE))
  .setAnimation({ dialogAnimation: AnimationType.UP_DOWN })
  .setConfig({ dialogBehavior: { isModal: true } })
  .setStyle({ backgroundColor: Color.White })
// [End get_toast]

// [Start dia_log]
let dialog:InfToast = DialogHub.getToast()
  // [StartExclude dia_log]
  .setContent(wrapBuilder(TextToastBuilder), new TextToastParams(CommonConstant.TOAST_TITLE))
  .setAnimation({ dialogAnimation: AnimationType.UP_DOWN })
  .setConfig({ dialogBehavior: { isModal: true } })
  .setStyle({ backgroundColor: Color.White })
    // [EndExclude dia_log]
  .build()
// [End dia_log]

// [Start show]
dialog.show()
// [End show]

// [Start dismiss]
dialog.dismiss()
// [End dismiss]

// [Start simple]
DialogHub.createToastTemplate('SimpleToast')
// [End simple]

// [Start create_set]
DialogHub.createToastTemplate('SimpleToast')
  .setContent(wrapBuilder(TextToastBuilder), new TextToastParams(CommonConstant.TOAST_TITLE))
  .setAnimation({ dialogAnimation: AnimationType.UP_DOWN })
  .setConfig({ dialogBehavior: { isModal: true } })
  .setStyle({ backgroundColor: Color.White })
// [End create_set]

// [Start wrap]
DialogHub.createToastTemplate('SimpleToast')
  // [StartExclude wrap]
  .setContent(wrapBuilder(TextToastBuilder), new TextToastParams(CommonConstant.TOAST_TITLE))
  .setAnimation({ dialogAnimation: AnimationType.UP_DOWN })
  .setConfig({ dialogBehavior: { isModal: true } })
  .setStyle({ backgroundColor: Color.White })
    // [EndExclude wrap]
  .register()
// [End wrap]

// [Start tem_plate]
DialogHub.getToastTemplate('SimpleToast')
  ?.setAnimation({dialogAnimation:AnimationType.FADE_IN_AND_OUT})
  .build()
  .show()
// [End tem_plate]

// [Start register]
DialogHub.updateToastTemplate('SimpleToast')
  ?.setStyle({backgroundColor:Color.Blue})
  .register()
// [End register]

// [Start remove1]
DialogHub.removeTemplate('SimpleToast')
// [End remove1]

// [Start exist1]
DialogHub.isTemplateExist('SimpleToast')
// [End exist1]