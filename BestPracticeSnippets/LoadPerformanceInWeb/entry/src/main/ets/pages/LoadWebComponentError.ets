// [Start load_web_component_error]
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct WebComponent {
  webviewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      // Load the business Web component at an appropriate time. This example takes the Button click trigger as an example.
      Button('加载页面')
        .onClick(() => {
          // Please replace url with real address.
          this.webviewController.loadUrl('https://www.example1.com/');
        })
      Web({ src: 'https://www.example.com/', controller: this.webviewController })
    }
  }
}
// [End load_web_component_error]