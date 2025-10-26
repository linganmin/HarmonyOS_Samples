/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */
import { GlobalContext } from "./GlobalContext";
import { hilog } from "@kit.PerformanceAnalysisKit";

const DOMAIN = 0x0000;
const TAG = 'Common';

export class Common {
  static getStringByNameSync(key: string): string {
    let value = '';
    try {
      value = GlobalContext.getContext().resourceManager.getStringByNameSync(key);
    } catch (err) {
      hilog.error(DOMAIN, TAG, `Failed to get key:${key}, code:${err.code}, message: ${err.message}`);
    }
    return value;
  }

  static getStringSync(resId: number): string {
    let value = '';
    try {
      value = GlobalContext.getContext().resourceManager.getStringSync(resId);
    } catch (err) {
      hilog.error(DOMAIN, TAG, `Failed to get resId:${resId}, code:${err.code}, message: ${err.message}`);
    }
    return value;
  }
}