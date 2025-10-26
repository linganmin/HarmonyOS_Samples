/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { LoginPage } from './LoginPage';
import { PersonalInfoPage } from './PersonalInfoPage';
import { ProtocolWebView } from './ProtocolWebView';
import { PrepareLoginPage } from './PrepareLoginPage';

const logTag: string = 'HomePage';
const domainId: number = 0x0000;

@Entry()
@Component
struct HomePage {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  aboutToAppear() {
    hilog.info(domainId, logTag, 'HomePage aboutToAppear');
  }

  aboutToDisappear() {
    hilog.info(domainId, logTag, 'userLogout: off');
  }

  onPageShow(): void {
    hilog.info(domainId, logTag, 'onPageShow');
  }

  onBackPress(): boolean | void {
    hilog.info(domainId, logTag, 'HomePage onBackPress');
    return true;
  }

  @Builder
  PageMap(name: string, params?: Record<string, Object>) {
    if (name === 'PrepareLoginPage') {
      PrepareLoginPage({ loginData: params })
    } else if (name === 'LoginPage') {
      LoginPage()
    } else if (name === 'PersonalInfoPage') {
      PersonalInfoPage()
    } else if (name === 'ProtocolWebView') {
      ProtocolWebView({ params: params })
    }
  }

  build() {
    Navigation(this.pageInfos) {
    }
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onAppear(async () => {
      this.pageInfos.replacePathByName('PrepareLoginPage', null, false);
    })
    .titleMode(NavigationTitleMode.Full)
    .hideTitleBar(true)
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.PageMap)
  }
}
