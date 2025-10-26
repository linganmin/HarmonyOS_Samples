// [Start clear_resource_cache]
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct WebComponent {
  webviewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Web({ src: 'https://www.example.com/', controller: this.webviewController })
        .onPageEnd(() => {
          // Clear the cache of pre-acquired resources that are no longer used in the future.
          webview.WebviewController.clearPrefetchedResource(['KeyX']);
        })
    }
  }
}
// [End clear_resource_cache]