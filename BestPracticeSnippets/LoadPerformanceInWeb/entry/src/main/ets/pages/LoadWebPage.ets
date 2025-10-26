// [Start load_web_page]
import { webview } from '@kit.ArkWeb';
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  controller: webview.WebviewController = new webview.WebviewController();


  build() {
    Column() {
      // Load business web components at the right time. This example is the example of Button click trigger.
      Button('加载页面')
        .onClick(() => {
          // Performance hit point
          hiTraceMeter.startTrace('getMessageData', 1);
          this.controller.loadUrl('https://www.example.com/b.html');
        })
      Web({ src: 'https://www.example.com/a.html', controller: this.controller })
        .fileAccess(true)
        .onPageEnd(() => {
          // Performance hit point
          hiTraceMeter.finishTrace('getMessageData', 1);
        })
    }
  }
}
// [End load_web_page]