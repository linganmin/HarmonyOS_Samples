import { hilog } from '@kit.PerformanceAnalysisKit';
import { safetyDetect } from '@kit.DeviceSecurityKit';
import { BusinessError} from '@kit.BasicServicesKit';

const TAG: string = '[SafetyDetectModel]';

function checkSysIntegrityPromise(): Promise<String> {
  return new Promise(async (resolve, reject) => {
    let strLen: number = 16;
    let srcStr: string = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefhijklmnopqrstuvwxyz0123456789";
    let randomStr: string = "";
    for (let i = 0; i < strLen; i++) {
      randomStr += srcStr.charAt(Math.floor(Math.random() * srcStr.length));
    }
    let sysIntegrityRequest: safetyDetect.SysIntegrityRequest = {
      nonce: randomStr
    }
    try {
      hilog.info(0x0000, TAG, 'CheckSysIntegrity begin.');
      let sysIntegrityResponse: safetyDetect.SysIntegrityResponse =
        await safetyDetect.checkSysIntegrity(sysIntegrityRequest);
      let result: string = sysIntegrityResponse.result;
      resolve(result);
      hilog.info(0x0000, TAG, 'Succeeded in checkSysIntegrity: %{public}s', result);
    }
    catch (err) {
      hilog.error(0x0000, TAG, 'CheckSysIntegrity failed: %{public}d %{public}s', err.code, err.message);
      reject(err);
    }
  });
}

function checkUrlThreatPromise(): Promise<String> {
  return new Promise(async (resolve, reject) => {
    let urlCheckRequest: safetyDetect.UrlCheckRequest = {
      urls: ['https://an.example.test','https://www.huawei.com']
    }
    try {
      hilog.info(0x0000, TAG, 'CheckUrlThreat begin.');
      let urlCheckResponse: safetyDetect.UrlCheckResponse = await safetyDetect.checkUrlThreat(urlCheckRequest);
      let results: safetyDetect.UrlCheckResult[]  = urlCheckResponse.results;
      let resultStr: string = "";
      for (let result of results) {
        let url: string =  result.url;
        let threat: safetyDetect.UrlThreatType =  result.threat;
        resultStr = resultStr + "url: " + url + "      threat: " + threat + "\n";
      }
      resolve(resultStr);
      hilog.info(0x0000, TAG, 'Succeeded in checkUrlThreat: %{public}s', resultStr);
    }
    catch (err) {
      hilog.error(0x0000, TAG, 'CheckUrlThreat failed: %{public}d %{public}s', err.code, err.message);
      reject(err);
    }
  });
}

function checkSysIntegrityOnLocalPromise(): Promise<String> {
  return new Promise(async (resolve, reject) => {
    let strLen: number = 16;
    let srcStr: string = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefhijklmnopqrstuvwxyz0123456789";
    let randomStr: string = "";
    for (let i = 0; i < strLen; i++) {
      randomStr += srcStr.charAt(Math.floor(Math.random() * srcStr.length));
    }
    let sysIntegrityRequest: safetyDetect.SysIntegrityRequest = {
      nonce: randomStr
    }
    try {
      hilog.info(0x0000, TAG, 'CheckSysIntegrityOnLocal begin.');
      let result: string = await safetyDetect.checkSysIntegrityOnLocal();
      resolve(result);
      hilog.info(0x0000, TAG, 'Succeeded in checkSysIntegrityOnLocal: %{public}s', result);
    }
    catch (err) {
      hilog.error(0x0000, TAG, 'CheckSysIntegrityOnLocal failed: %{public}d %{public}s', err.code, err.message);
      reject(err);
    }
  });
}

function checkSysIntegrityEnhancedPromise(): Promise<String> {
  return new Promise(async (resolve, reject) => {
    let strLen: number = 16;
    let srcStr: string = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefhijklmnopqrstuvwxyz0123456789";
    let randomStr: string = "";
    for (let i = 0; i < strLen; i++) {
      randomStr += srcStr.charAt(Math.floor(Math.random() * srcStr.length));
    }
    let sysIntegrityRequest: safetyDetect.SysIntegrityRequest = {
      nonce: randomStr
    }
    try {
      hilog.info(0x0000, TAG, 'CheckSysIntegrityEnhanced begin.');
      let sysIntegrityResponse: safetyDetect.SysIntegrityResponse =
        await safetyDetect.checkSysIntegrityEnhanced(sysIntegrityRequest);
      let result: string = sysIntegrityResponse.result;
      resolve(result);
      hilog.info(0x0000, TAG, 'Succeeded in checkSysIntegrityEnhanced: %{public}s', result);
    }
    catch (err) {
      hilog.error(0x0000, TAG, 'CheckSysIntegrityEnhanced failed: %{public}d %{public}s', err.code, err.message);
      reject(err);
    }
  });
}

export class SafetyDetectModel {
  private displayText: String = '';

  async checkSysIntegrity(callback: Function) {
    this.displayText = '';
    await checkSysIntegrityPromise().then((token) => {
      this.displayText = token;
      callback(this.displayText);
    }).catch((err: BusinessError) => {
      this.displayText = 'check SysIntegrity failed, errCode is ' + err.code;
      callback(this.displayText);
    });
  }

  async checkUrlThreat(callback: Function) {
    this.displayText = '';
    await checkUrlThreatPromise().then((token) => {
      this.displayText = token;
      callback(this.displayText);
    }).catch((err: BusinessError) => {
      this.displayText = 'check UrlThreat failed, errCode is ' + err.code;
      callback(this.displayText);
    });
  }

  async checkSysIntegrityOnLocal(callback: Function) {
    this.displayText = '';
    await checkSysIntegrityOnLocalPromise().then((token) => {
      this.displayText = token;
      callback(this.displayText);
    }).catch((err: BusinessError) => {
      this.displayText = 'check SysIntegrity on local failed, errCode is ' + err.code;
      callback(this.displayText);
    });
  }

  async checkSysIntegrityEnhanced(callback: Function) {
    this.displayText = '';
    await checkSysIntegrityEnhancedPromise().then((token) => {
      this.displayText = token;
      callback(this.displayText);
    }).catch((err: BusinessError) => {
      this.displayText = 'check SysIntegrity enhanced failed, errCode is ' + err.code;
      callback(this.displayText);
    });
  }
}

let safetyDetectModel = new SafetyDetectModel();

export default safetyDetectModel as SafetyDetectModel;
