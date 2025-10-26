/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
export const HAR_VERSION = '0.0.1';

export const BUILD_MODE_NAME = 'debug';

export const DEBUG = true;

export const TARGET_NAME = 'default';

/**
 * BuildProfile Class is used only for compatibility purposes.
 */
export default class BuildProfile {
  static readonly HAR_VERSION = HAR_VERSION;
  static readonly BUILD_MODE_NAME = BUILD_MODE_NAME;
  static readonly DEBUG = DEBUG;
  static readonly TARGET_NAME = TARGET_NAME;
}
