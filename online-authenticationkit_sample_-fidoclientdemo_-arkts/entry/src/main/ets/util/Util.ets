import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

interface Sp {
  type: string;
  userName: string;
  resp: string;
}

export class Util {
  public static fidoParameter(type: string, userAuthType: String) {
    let name: string = 'testName';
    let downloadCer = 'false';
    // 生物认证类型，指纹 ： 2， 人脸 ： 16
    let userVerify = userAuthType;
    let authType = 'auth';
    let deviceID = 'mate30test';
    let parameter: string = 'userName=' + name + '&type=' + type + '&downloadCer=' + downloadCer + '&userVerify=' + userVerify + '&authType=' + authType + '&deviceID=' + deviceID;
    return parameter;
  }

  public static connectFidoServer(url: string, str: string): Promise<string> {
    return new Promise((resolve) => {
      if (url !== null && url.length > 0) {
        let httpRequest = http.createHttp();
        httpRequest.request(
          url,
          {
            // 可选，默认为http.RequestMethod.GET
            method: http.RequestMethod.POST,
            // 开发者根据自身业务需要添加header字段
            header: {
              'Content-Type': 'application/x-www-form-urlencoded'
            },
            // 当使用POST请求时此字段用于传递内容
            extraData: str,
            // 可选，默认为1
            priority: 1,
            // 可选，默认为60000ms
            connectTimeout: 60000,
            // 可选，默认为60000ms
            readTimeout: 60000
          },
          (err, data) => {
            console.error(`Failed to connectFidoServer. Code: ${err.code}, message: ${err.message}`);
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

  public static SpP(spType: string, resp: string) {
    let fidoP: Sp = {
      type: spType,
      userName: 'testName',
      resp: resp
    }
    return fidoP
  }

  public static connectFidoServer1(url: string, str: Sp): Promise<string> {
    return new Promise((resolve) => {
      if (url !== null && url.length > 0) {
        let httpRequest = http.createHttp();
        httpRequest.request(
          url,
          {
            method: http.RequestMethod.POST, // 可选，默认为http.RequestMethod.GET
            // 开发者根据自身业务需要添加header字段
            header: {
              'Content-Type': 'application/json'
            },
            // 当使用POST请求时此字段用于传递内容
            extraData: str,
            priority: 1, // 可选，默认为1
            connectTimeout: 60000, // 可选，默认为60000ms
            readTimeout: 60000 // 可选，默认为60000ms
          },
          (err, data) => {
            console.error(`Failed to connectFidoServer1. Code: ${err.code}, message: ${err.message}`);
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

  // 字节流转成可理解的字符串
  public static uint8ArrayToString(array: Uint8Array) {
    let arrayString = '';
    for (let i = 0; i < array.length; i++) {
      arrayString += String.fromCharCode(array[i]);
    }
    return arrayString;
  }
}
