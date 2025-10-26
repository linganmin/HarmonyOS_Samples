/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 * */
import { FlutterAbility } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import FlutterEngine from '@ohos/flutter_ohos/src/main/ets/embedding/engine/FlutterEngine';
import MainPlugin from '../components/MainView';
import LoginPlugin from '../components/LoginView';
import UserInfoPlugin from '../components/UserInfoView';
import window from '@ohos.window';
import PrivacyPlugin from '../components/PrivacyView';

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    this.addPlugin(new LoginPlugin());
    this.addPlugin(new MainPlugin());
    this.addPlugin(new UserInfoPlugin());
    this.addPlugin(new PrivacyPlugin());
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    super.onWindowStageCreate(windowStage);
    windowStage.getMainWindow().then((windowClass) => {
      AppStorage.setOrCreate('uiContext', windowClass.getUIContext());
    });
  }
}
