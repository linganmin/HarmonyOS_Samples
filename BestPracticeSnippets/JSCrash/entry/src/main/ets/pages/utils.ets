import hilog from '@ohos.hilog';

const TAG: string = 'ZCM_Default';

const DOMAIN: number = 0x0011;
const SYMBOL: string = " --> ";

export class Log {
  /**
   * Outputs info-level logs.
   *
   * @param tag Identifies the log tag.
   * @param format Indicates the log format string.
   * @param args Indicates the log parameters.
   * @since 7
   */
  static showInfo(tag: string): void {
    if (Log.isLoggable(tag, hilog.LogLevel.INFO)) {
      hilog.info(DOMAIN, TAG, tag + SYMBOL);
    }
  }

  /**
   * Outputs debug-level logs.
   *
   * @param tag Identifies the log tag.
   * @param format Indicates the log format string.
   * @param args Indicates the log parameters.
   * @since 7
   */
  static showDebug(tag: string, format: string, ...args: string[]): void {
    if (Log.isLoggable(tag, hilog.LogLevel.DEBUG)) {
      hilog.debug(DOMAIN, TAG, tag + SYMBOL + format, args);
    }
  }

  /**
   * Outputs warning-level logs.
   *
   * @param tag Identifies the log tag.
   * @param format Indicates the log format string.
   * @param args Indicates the log parameters.
   * @since 7
   */
  static showWarn(tag: string, format: string, ...args: string[]): void {
    if (Log.isLoggable(tag, hilog.LogLevel.WARN)) {
      hilog.warn(DOMAIN, TAG, tag + SYMBOL + format, args);
    }
  }

  /**
   * Outputs error-level logs.
   *
   * @param tag Identifies the log tag.
   * @param format Indicates the log format string.
   * @param args Indicates the log parameters.
   * @since 7
   */
  static showError(tag: string): void {
    if (Log.isLoggable(tag, hilog.LogLevel.ERROR)) {
      hilog.error(DOMAIN, TAG, tag + SYMBOL);
    }
  }

  /**
   * Outputs fatal-level logs.
   *
   * @param tag Identifies the log tag.
   * @param format Indicates the log format string.
   * @param args Indicates the log parameters.
   * @since 7
   */
  static showFatal(tag: string, format: string, ...args: string[]): void {
    if (Log.isLoggable(tag, hilog.LogLevel.FATAL)) {
      hilog.fatal(DOMAIN, TAG, tag + SYMBOL + format, args);
    }
  }

  /**
   * Checks whether logs of the specified tag, and level can be printed.
   *
   * @param tag Identifies the log tag.
   * @param level log level
   * @since 7
   */
  private static isLoggable(tag: string, level: hilog.LogLevel): boolean {
    return hilog.isLoggable(DOMAIN, tag, level);
  }
}