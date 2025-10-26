/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 * */

import common from '@ohos.app.ability.common';
import { FlutterPage } from '@ohos/flutter_ohos'

const uiContext = AppStorage.get('uiContext') as UIContext;
const storage = uiContext.getSharedLocalStorage();
const EVENT_BACK_PRESS = 'EVENT_BACK_PRESS';

@Entry(storage)
@Component
struct Index {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @LocalStorageLink('viewId') viewId: string = "";

  build() {
    Column() {
      FlutterPage({ viewId: this.viewId });
    }
  }

  onBackPress(): boolean {
    this.context.eventHub.emit(EVENT_BACK_PRESS)
    return true
  }
}