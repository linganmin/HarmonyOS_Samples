// [Start web_develop_optimization]
// Index.ets
import { webview } from '@kit.ArkWeb';
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  controller: webview.WebviewController = new webview.WebviewController();
  responseResource: WebResourceResponse = new WebResourceResponse();
  // The developer defines the response data, and the length of the response data must be greater than or equal to 1024 to generate CodeCache.
  @State jsData: string = 'JavaScript Data';

  build() {
    Column() {
      Web({ src: $rawfile('index.html'), controller: this.controller })
        .onInterceptRequest((event) => {
          // Intercept page requests
          if (event?.request.getRequestUrl() === 'https://www.example.com/test.js') {
            // Construct response data
            this.responseResource.setResponseHeader([
              {
                // Format: No more than 13 digits. Js ID, this field must be updated when Js is updated.
                headerKey: 'ResponseDataID',
                headerValue: '0000000000001'
              }]);
            this.responseResource.setResponseData(this.jsData);
            this.responseResource.setResponseEncoding('utf-8');
            this.responseResource.setResponseMimeType('application/javascript');
            this.responseResource.setResponseCode(200);
            this.responseResource.setReasonMessage('OK');
            return this.responseResource;
          }
          return null;
        })
        .onPageBegin(() => {
          hiTraceMeter.startTrace('getMessageData', 0);
        })
        .onPageEnd(() => {
          hiTraceMeter.finishTrace('getMessageData', 0);
        })
    }
  }
}

// [End web_develop_optimization]