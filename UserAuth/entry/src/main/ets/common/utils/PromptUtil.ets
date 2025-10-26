/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import CommonConstants from '../constants/CommonConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
/**
 * Prompt util
 */
class PromptUtil {
  /**
   * A dialog box is displayed.
   * @param message
   * @param time
   * @param bottom
   */
  promptMessage(message: string | Resource, time: number, bottom: string | number = CommonConstants.PROMPT_BOTTOM) {
    try {
      uiContext?.getPromptAction().showToast({
        message: message,
        duration: time,
        bottom: bottom
      })
    } catch (error) {
      hilog.error(0x0000, 'UserAuth', `showToast error ${JSON.stringify(error)}`);
    }
  }
}

export default new PromptUtil();