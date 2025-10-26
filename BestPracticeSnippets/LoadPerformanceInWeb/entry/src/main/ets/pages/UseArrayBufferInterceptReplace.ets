// [Start use_array_buffer_intercept_replace]
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct WebComponent {
  controller: webview.WebviewController = new webview.WebviewController()
  scheme1: webview.WebCustomScheme = { schemeName: "imeituan", isSupportCORS: true, isSupportFetch: true }
  responseResource: WebResourceResponse = new WebResourceResponse()
  // Developer Custom Response Data
  data: string = "";
  buffer: ArrayBuffer = new ArrayBuffer(this.data.length);
  usingLen: number = 1;

  aboutToAppear(): void {
    // Configure the Web to open the debugging mode
    webview.WebviewController.setWebDebuggingAccess(true);

    try {
      webview.WebviewController.customizeSchemes([this.scheme1])
      console.info(`customizeSchemes`)
    } catch (error) {
      console.error(error);
    }

    this.initArrayBufferData(1);
  }

  onPageShow(): void {

  }

  initStringData(size: Number): void {
    switch (size){
      case 1:
        this.usingLen = 10; //10k
        break;
      case 2:
        this.usingLen = 1024; //1M
        break;
      case 3:
        this.usingLen = 1024 * 10; //10M
        break;
      default:
        this.usingLen = 1;
    }

    let str: string = "";
    let str_1k: string = "";
    for (let i = 0 ; i < 1024; i++) {
      str_1k = str_1k.concat("x");
    }
    for (let j = 0; j < this.usingLen; j++) {
      str = str.concat(str_1k);
    }

    this.data = JSON.stringify({
      status: 200,
      result: str,
    });
    console.info("init data length: " + this.data.length);
  }

  // size - 1:10k, 2:1M, 3:10M
  initArrayBufferData(size:Number): void {
    this.initStringData(size);
    console.error("target string: " + this.data);
    this.buffer = new ArrayBuffer(this.data.length);
    const uint8Array: Uint8Array = new Uint8Array(this.buffer);
    for (let i = 0; i < this.data.length; i++) {
      uint8Array[i] = this.data.charCodeAt(i);
    }
  }

  build() {
    Column() {
      Button('set to 10K')
        .onClick(() => {
          this.initArrayBufferData(1);
          console.log("datalen set to length "+ this.buffer.byteLength);
        })
      Button('set to 1M')
        .onClick(() => {
          this.initArrayBufferData(2);
          console.log("datalen set to length "+ this.buffer.byteLength);
        })
      Button('set to 10M')
        .onClick(() => {
          this.initArrayBufferData(3);
          console.log("datalen set to length "+ this.buffer.byteLength);
        })
      Web({ src: $rawfile("intercept.html"), controller: this.controller })
        .onConsole((event) => {
          console.error(`ygz ${event?.message?.getMessage()}`);
          return true;
        })
        .onInterceptRequest((event) => {
          if (event) {
            console.error('url:' + event.request.getRequestUrl());
            // Block Page Request
            if (!event.request.getRequestUrl().startsWith('http://bridge')) {
              return null;
            }
          }
          // Construct response data
          // const str: string = buffer.from(this.buffer).toString();
          console.error("response data length: " + this.data.length);
          this.responseResource.setResponseData(this.buffer);
          this.responseResource.setResponseEncoding('utf-8');
          this.responseResource.setResponseMimeType('text/json');
          this.responseResource.setResponseCode(200);
          this.responseResource.setReasonMessage('OK');
          this.responseResource.setResponseHeader([{ headerKey: 'Access-Control-Allow-Origin', headerValue: '*' }]);
          console.info(`ygz return reponse`);
          return this.responseResource;
        })
    }
  }
}
// [End use_array_buffer_intercept_replace]