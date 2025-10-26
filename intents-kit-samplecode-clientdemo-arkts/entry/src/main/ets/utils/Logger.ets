import { hilog } from '@kit.PerformanceAnalysisKit';

export class Logger {
  private static readonly DOMAIN: number = 0x0000;
  private static readonly TAG: string = 'com.example.insightintentdemo';

  public static debug(logTag: string, messageFormat: string, ...args: Object[]): void {
    hilog.debug(Logger.DOMAIN, Logger.TAG, `${Logger.DOMAIN} ${logTag}: ${messageFormat}`, args);
  }

  public static info(logTag: string, messageFormat: string, ...args: Object[]): void {
    hilog.info(Logger.DOMAIN, Logger.TAG, `${Logger.DOMAIN} ${logTag}: ${messageFormat}`, args);
  }

  public static warn(logTag: string, messageFormat: string, ...args: Object[]): void {
    hilog.warn(Logger.DOMAIN, Logger.TAG, `${Logger.DOMAIN} ${logTag}: ${messageFormat}`, args);
  }

  public static error(logTag: string, messageFormat: string, ...args: Object[]): void {
    hilog.error(Logger.DOMAIN, Logger.TAG, `${Logger.DOMAIN} ${logTag}: ${messageFormat}`, args);
  }

  public static fatal(logTag: string, messageFormat: string, ...args: Object[]): void {
    hilog.fatal(Logger.DOMAIN, Logger.TAG, `${Logger.DOMAIN} ${logTag}: ${messageFormat}`, args);
  }

  private constructor() {
  }
}
