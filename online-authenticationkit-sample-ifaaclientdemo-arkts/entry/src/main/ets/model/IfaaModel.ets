import {ifaa} from '@kit.OnlineAuthenticationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Util } from '../util/Util';

type DataPair = Record<string, [string, string, string, string]>;
const SERVER_URL: string = 'Ifaa server URL' // Ifaa server url

export class IfaaModel {
  /* sample data */
  private tlvRegisterReqFace: string = '';
  private tlvRegisterReqFp: string = '';
  private tlvAuthReqFace: string = '';
  private tlvAuthReqFp: string = '';
  private tlvDeregisterReqFace: string = '';
  private tlvDeregisterReqFp: string = '';
  private queryReqFace: string = '';
  private queryReqFp: string = '';
  private sampleData: DataPair | undefined = undefined;

  /* Simulate interacting with the server and fetching data */
  public async initReqData(): Promise<void> {
    const parameter: string = 'test get request data';
    const initRes = await Util.connectIfaaServer(SERVER_URL, parameter);
    try {
      const parseData: ESObject = JSON.parse(initRes);
      this.tlvRegisterReqFace = parseData.tlvRegisterReqFace;
      this.tlvRegisterReqFp = parseData.tlvRegisterReqFp;
      this.tlvAuthReqFace = parseData.tlvAuthReqFace;
      this.tlvAuthReqFp = parseData.tlvAuthReqFp;
      this.tlvDeregisterReqFace = parseData.tlvDeregisterReqFace;
      this.tlvDeregisterReqFp = parseData.tlvDeregisterReqFp;
      this.queryReqFace = parseData.queryReqFace;
      this.queryReqFp = parseData.queryReqFp;
    } catch (err) {
      console.error(`Failed to connectServiceExtensionAbility. Code: ${err.code}, message: ${err.message}`);
    }
    this.sampleData = {
      "face": [this.tlvRegisterReqFace, this.tlvAuthReqFace, this.tlvDeregisterReqFace, this.queryReqFace],
      "fp": [this.tlvRegisterReqFp, this.tlvAuthReqFp, this.tlvDeregisterReqFp, this.queryReqFp]
    };
  }

  public register(dataType: string): Promise<Uint8Array|null> {
    // 检查IIFAA免密认证能力是否已经开通
    if (!this.sampleData || this.sampleData[dataType] === null) {
      console.error("invalid parameters!")
      throw new Error("invalid parameters");
    }
    let data = this.sampleData[dataType];
    let registerRes = ifaa.queryStatusSync(this.stringToUint8Array(data[3]));
    if (registerRes === true) {
      throw new Error("iifaa already registered");
    }

    // 替换IIFAA中心服务器签名下发的数据
    return ifaa.register(this.hexToBytes(data[0]));
  }

  public auth(dataType: string, authToken: Uint8Array): Promise<Uint8Array|null> {
    if (!this.sampleData || authToken === null) {
      console.error("invalid parameters!")
      throw new Error("invalid parameters!");
    }
    let data = this.sampleData[dataType];
    // 替换IIFAA中心服务器签名下发的数据
    return ifaa.auth(authToken, this.hexToBytes(data[1]));
  }

  public deregister(dataType: string): Promise<void> {
    if (!this.sampleData || this.sampleData[dataType] === null) {
      console.error("invalid parameters!")
      throw new TypeError("Error message");
    }
    let data = this.sampleData[dataType];
    // 替换IIFAA中心服务器签名下发的数据
    return ifaa.deregister(this.hexToBytes(data[2]));
  }

  public getChallenge(): Uint8Array {
    return ifaa.preAuthSync();
  }

  private stringToUint8Array(str:string): Uint8Array {
    let arr: number[] = [];
    let ss = "";
    console.info("IIFAA: " + str.length);
    for (let i = 0, j = str.length + 1; i < j; ++i) {
      arr.push(str.charCodeAt(i));
      ss += str.charCodeAt(i);
    }
    let tmpArray = new Uint8Array(arr);
    console.info("IIFAA: value: " + ss);
    return tmpArray;
  }

  private hexToBytes(hex: string): Uint8Array {
    let bytes:number[] = [];
    for (let c = 0; c < hex.length; c += 2)
      bytes.push(parseInt(hex.substring(c, c+2), 16));
    return new Uint8Array(bytes);
  }
}

let ifaaWrapper = new IfaaModel();
export default ifaaWrapper as IfaaModel;