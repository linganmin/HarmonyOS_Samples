// [Start case_four]
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct WebComponent {
  webviewController: webview.WebviewController = new webview.WebviewController();
  build() {
    Column() {
      Web({ src: 'https://www.example.com/', controller: this.webviewController})
        .onPageEnd(() => {
          // Pre-connected https://www.iana.org/help/example-domains
          this.webviewController.prefetchPage('https://www.iana.org/help/example-domains');
        })
    }
  }
}
// [End case_four]