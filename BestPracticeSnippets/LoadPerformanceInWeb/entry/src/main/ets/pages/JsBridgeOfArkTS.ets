// [Start js_bridge_of_arkTs]
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct WebComponent {
  webviewController: webview.WebviewController = new webview.WebviewController();

  aboutToAppear(): void {
    // Configure the Web to open the debugging mode
    webview.WebviewController.setWebDebuggingAccess(true);
  }

  build() {
    Column() {
      Button('runJavaScript')
        .onClick(() => {
          console.info('现在时间是:' + new Date().getTime());
          // When the front-end page function has no parameters, delete the param.
          this.webviewController.runJavaScript('htmlTest(param)');
        })
      Button('runJavaScriptCodePassed')
        .onClick(() => {
          // Pass runJavaScript side code method
          this.webviewController.runJavaScript(`function changeColor(){document.getElementById('text').style.color = 'red'}`);
        })
      Web({ src: $rawfile('index.html'), controller: this.webviewController })
    }
  }
}
// [End js_bridge_of_arkTs]