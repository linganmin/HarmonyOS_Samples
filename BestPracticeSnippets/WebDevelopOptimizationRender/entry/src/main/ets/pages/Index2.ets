// DocsCode 1
// Second.ets
import { webview } from '@kit.ArkWeb';
import { getNWeb } from './common';

@Builder
export function PageOneBuilder() {
  Second()
}

@Component
export struct Second {
  webviewController: webview.WebviewController = new webview.WebviewController();
  aboutToAppear(): void {
    // 输出Web页面开始加载时间
    console.info(`load page start time: ${Date.now()}`);
  }
  build() {
    NavDestination() {
      Row() {
        Column() {
          // url请替换为真实地址
          NodeContainer(getNWeb('https://www.example.com'))
            .height('100%')
            .width('100%')
        }
        .width('100%')
      }
      .height('100%')
    }
  }
}
// DocsCode 1