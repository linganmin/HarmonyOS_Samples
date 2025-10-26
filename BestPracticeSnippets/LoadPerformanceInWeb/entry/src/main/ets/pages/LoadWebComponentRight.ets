// [Start load_web_component_right]
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct WebComponent {
  controller: webview.WebviewController = new webview.WebviewController();
  webviewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      // Load the business Web component at an appropriate time. This example takes the Button click trigger as an example.
      Button('加载页面')
        .onClick(() => {
          // Performance dot
          hiTraceMeter.startTrace('getMessageData', 1);
          // Please replace url with real address.
          this.controller.loadUrl('https://www.example1.com/');
        })
      Web({ src: 'https://www.example.com/', controller: this.webviewController })
        .onPageEnd(() => {
          // When pre-acquiring, 'https://www.example1.com/POST? E=f&g=h' is replaced by the actual website address to be visited.
          webview.WebviewController.prefetchResource(
            {
              url: 'https://www.example1.com/POST?e=f&g=h',
              method: 'POST',
              formData: 'a=x&b=y'
            },
            [{
              headerKey: 'c',
              headerValue: 'z'
            }],
            'KeyX', 500
          );
        })
    }
  }
}
// [End load_web_component_right]