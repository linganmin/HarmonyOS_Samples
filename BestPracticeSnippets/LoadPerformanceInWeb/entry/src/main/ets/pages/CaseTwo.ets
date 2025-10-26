// [Start case_two]
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct WebComponent {
  webviewController: webview.WebviewController = new webview.WebviewController();
  build() {
    Column() {
      Button('loadData')
        .onClick(() => {
          if (this.webviewController.accessBackward()) {
            this.webviewController.backward();
          }
        })
      Web({ src: 'https://www.example.com/cn/', controller: this.webviewController})
        .onAppear(() => {
          // Specify that the second parameter is true, which means to pre-connect. If it is false, the interface will only pre-resolve the URL.
          // The third parameter is the number of socket to be pre-connected. A maximum of six are allowed.
          webview.WebviewController.prepareForPageLoad('https://www.example.com/cn/', true, 2);
        })
    }
  }
}
// [End case_two]