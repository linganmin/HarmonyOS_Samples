
import { webview } from '@kit.ArkWeb';

let nativeObj:object ;

@Component
struct webmessagepage {
  private webviewController: webview.WebviewController = new webview.WebviewController();
  // [Start web]
  build() {
    Column() {
      //The Web component loads the local index.html page.
      Web({
        src: './Index',
        controller: new webview.WebviewController()
      })
        //Inject objects into the web side.
        .javaScriptProxy({
        object: nativeObj,
        name: "nativeObj",
        methodList: ["makePhoneCall"],
        controller: new webview.WebviewController()
      })
    }
  }
  // [End web]
}
