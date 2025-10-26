/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

import { BusinessError } from '@kit.BasicServicesKit';
import { ErrorCode } from '../common/Constants';

export default class Utils {
  private static callerBundleName: string = '';

  /**
   * set caller bundleName
   *
   * @param - the caller bundle name
   */
  public static setCallerBundleName(callerBundleName: string): void {
    Utils.callerBundleName = callerBundleName;
  }

  /**
   * set caller bundleName
   *
   * @returns { string } the caller bundle name
   */
  public static getCallerBundleName(): string {
    return Utils.callerBundleName;
  }

  /**
   * is the caller Digital Balance
   *
   * @returns { boolean } is the caller Digital Balance
   */
  public static isCallerParentControl(): boolean {
    return Utils.callerBundleName === 'com.huawei.hmos.parentcontrol';
  }

  /**
   * exception handling function
   *
   * @param error - error that needs to be processed
   */
  public static dealAllError(error: BusinessError): void {
    switch (error.code) {
      case ErrorCode.ERROR_CODE_PERMISSION_VERIFY_FAIL:
        // Permission verification failed.
        break;
      case ErrorCode.ERROR_CODE_PARAMETER_ERROR:
        // Parameter error.
        break;
      case ErrorCode.ERROR_CODE_CAPABILITY_NOT_SUPPORT:
        // Capability not supported.
        break;
      case ErrorCode.ERROR_CODE_INTERNAL_ERROR:
        // Internal error.
        break;
      case ErrorCode.ERROR_CODE_NOT_AUTHORIZED:
        // The user has not authorized the application to access this interface.
        break;
      case ErrorCode.ERROR_CODE_USER_CANCELED:
        // The user canceled the operation.
        break;
      case ErrorCode.ERROR_CODE_STRATEGIES_EXCEEDS_LIMIT:
        // The number of strategies exceeds the upper limit.
        break;
      case ErrorCode.ERROR_CODE_STRATEGY_NAME_ALREADY_EXIST:
        // The strategy name is already existed.
        break;
      case ErrorCode.ERROR_CODE_NONEXISTENT_STRATEGY:
        // Nonexistent strategy.
        break;
      case ErrorCode.ERROR_CODE_STRATEGY_EXECUTED:
        // The strategy is already being executed.
        break;
      case ErrorCode.ERROR_CODE_STRATEGY_NOT_START:
        // This strategy has not been started yet.
        break;
      default:
        // Other Errors.
        break;
    }
  }
}