/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

import prompt from '@ohos.promptAction';

/**
 * Toast显示工具类
 */
export class ToastUtils {
  private static SHORT_SHOW_TIME = 1800;
  private static MARGIN_BOTTOM = 100;

  /**
   * 短暂显示底部toast
   *
   * @param message 显示信息
   */
  static showShortToastNormal(message: string | Resource): void {
    prompt.openToast({
      message: message,
      duration: ToastUtils.SHORT_SHOW_TIME,
      bottom: ToastUtils.MARGIN_BOTTOM
    });
  }
}