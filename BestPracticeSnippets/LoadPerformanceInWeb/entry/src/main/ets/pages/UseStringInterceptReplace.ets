// [Start use_string_intercept_replace]
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct Index {
  controller: webview.WebviewController = new webview.WebviewController();
  responseResource: WebResourceResponse = new WebResourceResponse();
  // Here is the string format data.
  resourceStr: string = 'xxxxxxxxxxxxxxx';

  build() {
    Column() {
      Web({ src: 'https:www.example.com/test.html', controller: this.controller })
        .onInterceptRequest(event => {
          if (event) {
            if (!event.request.getRequestUrl().startsWith('https://www.example.com/')) {
              return null;
            }
          }
          // Use string format data for interception and replacement
          this.responseResource.setResponseData(this.resourceStr);
          this.responseResource.setResponseEncoding('utf-8');
          this.responseResource.setResponseMimeType('text/json');
          this.responseResource.setResponseCode(200);
          this.responseResource.setReasonMessage('OK');
          this.responseResource.setResponseHeader([{ headerKey: 'Access-Control-Allow-Origin', headerValue: '*' }]);
          return this.responseResource;
        })
    }
  }
}
// [End use_string_intercept_replace]