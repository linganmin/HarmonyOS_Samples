// [Start js_bridge_of_ndk]
import testNapi from 'libentry.so';
import { webview } from '@kit.ArkWeb';

class testObj {
  constructor() {
  }

  test(): string {
    console.log('ArkUI Web Component');
    return "ArkUI Web Component";
  }

  toString(): void {
    console.log('Web Component toString');
  }
}

@Entry
@Component
struct Index {
  webTag: string = 'ArkWeb1';
  controller: webview.WebviewController = new webview.WebviewController(this.webTag);
  @State testObjtest: testObj = new testObj();

  aboutToAppear(): void {
    console.info("aboutToAppear");
    // init web ndk
    testNapi.nativeWebInit(this.webTag);
  }

  build() {
    Column() {
      Row() {
        Button('runJS hello')
          .fontSize(12)
          .onClick(() => {
            console.log('start:---->'+new Date().getTime());
            testNapi.runJavaScript(this.webTag, "runJSRetStr(\"" + "hello" + "\")");
          })
      }.height('20%')

      Row() {
        Web({ src: $rawfile('runJS.html'), controller: this.controller })
          .javaScriptAccess(true)
          .fileAccess(true)
          .onControllerAttached(() => {
            console.error("ndk onControllerAttached webId: " + this.controller.getWebId());
          })
      }.height('80%')
    }
  }
}
// [End js_bridge_of_ndk]