/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

export namespace Constants {
  // caller package name key in Ability want
  export const PARAM_CALLER_BUNDLE_NAME: string = 'ohos.aafwk.param.callerBundleName';
  // the strategy name for daily repeated strategy in the demo
  export const STRATEGY_NAME: string = 'Setting_Duplicate_Control_Rules';
  // the repetition cycle of the strategy
  export const REPEAT_DAILY: number[] = [1, 2, 3, 4, 5, 6, 7];
  // title of the effective time period for guard strategy
  export const GUARD_PERIOD_TITLE: string = '19:00 - 21:00';
  // guard strategy start time
  export const GUARD_START_TIME: string = '19:00';
  // guard strategy end time
  export const GUARD_END_TIME: string = '21:00';
  // UI parameter
  export const MATCH_PARENT: string = '100%';
  // immediate and customizable control policies, select mutually exclusive anti-click time, unit: milliseconds
  export const SAFE_ASSIGN_TIME: number = 100;
}

export enum ErrorCode {
  // Permission verification failed.
  ERROR_CODE_PERMISSION_VERIFY_FAIL = 201,
  // Parameter error.
  ERROR_CODE_PARAMETER_ERROR = 401,
  // Capability not supported.
  ERROR_CODE_CAPABILITY_NOT_SUPPORT = 801,
  // Internal error.
  ERROR_CODE_INTERNAL_ERROR = 1019000001,
  // The user has not authorized the application to access this interface.
  ERROR_CODE_NOT_AUTHORIZED = 1019000002,
  // The user canceled the operation.
  ERROR_CODE_USER_CANCELED = 1019000003,
  // The number of strategies exceeds the upper limit.
  ERROR_CODE_STRATEGIES_EXCEEDS_LIMIT = 1019000004,
  // The strategy name is already existed.
  ERROR_CODE_STRATEGY_NAME_ALREADY_EXIST = 1019000005,
  // Nonexistent strategy.
  ERROR_CODE_NONEXISTENT_STRATEGY = 1019000006,
  // The strategy is already being executed.
  ERROR_CODE_STRATEGY_EXECUTED = 1019000007,
  // This strategy has not been started yet.
  ERROR_CODE_STRATEGY_NOT_START = 1019000008
}