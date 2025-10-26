import { http } from "@kit.NetworkKit"
import { hilog } from "@kit.PerformanceAnalysisKit";

export class Util {
  public static connectIfaaServer(url: string, str: string): Promise<string> {
    return new Promise((resolve) => {
      if (url !== null && url !== undefined && url.length > 0) {
        let httpRequest = http.createHttp();
        httpRequest.request(
          url,
          {
            // Optional. The default value is http.RequestMethod.GET.
            method: http.RequestMethod.POST,
            // You can add header fields based on service requirements.
            header: {
              'Content-Type': 'application/x-www-form-urlencoded'
            },
            // Use this field to transfer information in a POST request.
            extraData: str,
            // Optional. The default value is 1.
            priority: 1,
            // Optional. The default value is 60000, in ms.
            connectTimeout: 60000,
            // Optional. The default value is 60000, in ms.
            readTimeout: 60000
          },
          (err, data) => {
            console.error(`Failed to connectIfaaServer. Code: ${err.code}, message: ${err.message}`);
            if (!err) {
              hilog.info(0x0000, 'TAG', `test... ${JSON.stringify(data)}`);
              let result = data.result.toString();
              httpRequest.destroy();
              resolve(result);
            }
          }
        );
      }
    });
  }
}