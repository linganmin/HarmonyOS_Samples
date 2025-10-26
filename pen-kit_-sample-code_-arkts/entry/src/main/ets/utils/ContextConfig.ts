/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { common } from "@kit.AbilityKit";


declare namespace globalThis {
  let _brushEngineContext: common.UIAbilityContext;
};

export default class GlobalContext {

  static getContext(): common.UIAbilityContext {
    return globalThis._brushEngineContext;
  }

  static setContext(context: common.UIAbilityContext): void {
    globalThis._brushEngineContext = context;
  }
}

