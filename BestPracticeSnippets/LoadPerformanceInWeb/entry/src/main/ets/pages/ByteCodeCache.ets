import { webview } from '@kit.ArkWeb';
import business_error from '@kit.BasicServicesKit'

@Component
struct ByteCodeCache {
  // [Start scheme_one]
  scheme1: webview.WebCustomScheme = { schemeName: "scheme1", isSupportCORS: true, isSupportFetch: true, isCodeCacheSupported: true }
  // [End scheme_one]
  webController: webview.WebviewController = new webview.WebviewController();
  @State jsData: string = 'JavaScript Data';
  @State jsData2: string = 'JavaScript Data';

  // [Start about_to_appear]
  aboutToAppear(): void {
    try {
      webview.WebviewController.customizeSchemes([this.scheme1])
    } catch (error) {
      let e: business_error.BusinessError = error as business_error.BusinessError;
      console.error(`ErrorCode: ${e.code},  Message: ${e.message}`);
    }
  }
  // [End about_to_appear]

  build() {
    Column() {
      // [Start byte_code_cache_web]
      Web({
        src: $rawfile('index.html'),
        controller: this.webController
      })
        .fileAccess(true)
        .javaScriptAccess(true)
        .width('100%')
        .height('100%')
        .onConsole((event) => {
          console.log('ets onConsole:' + event?.message.getMessage());
          return false
        })
        .onInterceptRequest((event) => {
          let responseResource = new WebResourceResponse()
          // Intercept page requests
          if (event?.request.getRequestUrl() == 'https://www.intercept.com/test-cc.js') {
            // Construct response data
            responseResource.setResponseHeader([
              {
                headerKey: 'ResponseDataID',
                headerValue: '0000000000002'
                // Format: No more than 13 digits. Js ID, this field must be updated when Js is updated.
              }]);
            responseResource.setResponseData(this.jsData);
            responseResource.setResponseEncoding('utf-8');
            responseResource.setResponseMimeType('application/javascript');
            responseResource.setResponseCode(200);
            responseResource.setReasonMessage('OK');
            return responseResource;


          }
          if (event?.request.getRequestUrl() == 'scheme1://www.intercept.com/test-cc2.js') {
            // Construct response data
            responseResource.setResponseHeader([
              {
                headerKey: 'ResponseDataID',
                headerValue: '0000000000001'
                // Format: No more than 13 digits. Js ID, this field must be updated when Js is updated.
              }]);
            responseResource.setResponseData(this.jsData2);
            responseResource.setResponseEncoding('utf-8');
            responseResource.setResponseMimeType('application/javascript');
            responseResource.setResponseCode(200);
            responseResource.setReasonMessage('OK');
            return responseResource;
          }
          return null;
        })
      // // [End byte_code_cache_web]
    }
  }
}