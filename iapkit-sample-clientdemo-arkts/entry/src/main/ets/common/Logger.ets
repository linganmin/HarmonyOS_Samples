/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */

import { hilog } from '@kit.PerformanceAnalysisKit';

export default class Logger {
  private static IAP_DEMO_PREFIX: string = '[IAP_Demo]';

  private static IAP_LOG_DOMIN = 0x0fff;

  // 日志格式：TAG message
  private static TWO_PLACEHOLDER_FORMAT: string = '%{public}s    %{public}s';

  public static info(tag: string, log: string) {
    hilog.info(Logger.IAP_LOG_DOMIN, Logger.IAP_DEMO_PREFIX, Logger.TWO_PLACEHOLDER_FORMAT, tag, log);
  }

  public static debug(tag: string, log: string) {
    hilog.debug(Logger.IAP_LOG_DOMIN, Logger.IAP_DEMO_PREFIX, Logger.TWO_PLACEHOLDER_FORMAT, tag, log);
  }

  public static warn(tag: string, log: string) {
    hilog.warn(Logger.IAP_LOG_DOMIN, Logger.IAP_DEMO_PREFIX, Logger.TWO_PLACEHOLDER_FORMAT, tag, log);
  }

  public static error(tag: string, log: string) {
    hilog.error(Logger.IAP_LOG_DOMIN, Logger.IAP_DEMO_PREFIX, Logger.TWO_PLACEHOLDER_FORMAT, tag, log);
  }

}
