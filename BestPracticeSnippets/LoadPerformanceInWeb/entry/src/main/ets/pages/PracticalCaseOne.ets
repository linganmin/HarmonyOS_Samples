// [Start practical_case_one]
import { webview } from '@kit.ArkWeb';
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  controller: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      // Load the business Web component at an appropriate time. This example takes the Button click trigger as an example.
      Button('加载页面')
        .onClick(() => {
          // Performance dot
          hiTraceMeter.startTrace('unPrecompileJavaScript', 1);
          // Please replace url with real address.
          this.controller?.loadUrl('https://www.example.com/b.html');
        })
      Web({ src: 'https://www.example.com/a.html', controller: this.controller })
        .fileAccess(true)
        .onPageBegin((event) => {
          console.log(`load page begin: ${event?.url}`);
        })
        .onPageEnd((event) => {
          // Performance dot
          hiTraceMeter.finishTrace('unPrecompileJavaScript', 1);
          console.log(`load page end: ${event?.url}`);
        })
    }
  }
}
// [End practical_case_one]