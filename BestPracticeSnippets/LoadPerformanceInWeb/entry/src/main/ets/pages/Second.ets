// [Start page_second]
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
    // Output Web page start loading time
    console.info(`load page start time: ${Date.now()}`);
  }
  build() {
    NavDestination() {
      Row() {
        Column() {
          // Please replace url with real address.
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
// [End page_second]