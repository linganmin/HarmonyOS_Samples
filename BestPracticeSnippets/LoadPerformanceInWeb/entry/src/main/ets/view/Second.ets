// [Start page_index]
// Second.ets
import { webview } from '@kit.ArkWeb'

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
          Web({ src: 'https://www.example.com', controller: this.webviewController })
            .height('100%')
            .width('100%')
            .onPageEnd((event) => {
              // Output Web page loading completion time
              console.info(`load page end time: ${Date.now()}`);
            })
        }
        .width('100%')
      }
      .height('100%')
    }
  }
}
// [End page_index]