import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
// Please check the readme.md
// In the project path, run the command on the console:ohpm i @hw-agconnect/petal-aegis
import { AegRsaSign } from "@hw-agconnect/petal-aegis";

const TAG: string = 'SignUtil';
const SEPARATOR: string = '\u2063';

export class SignUtil {
  public static genSignContent(adTechId: string, campaignId: string, destinationId: string, mmpIds: string[], serviceTag: string, nonce: string, timestamp: number) {
    let content = SignUtil.addSeparator(adTechId)
      + SignUtil.addSeparator(campaignId)
      + SignUtil.addSeparator(destinationId)
      + SignUtil.addSeparator(serviceTag)
      + SignUtil.genMmpIds(mmpIds)
      + SignUtil.addSeparator(nonce)
      + timestamp;
    hilog.info(0,TAG,`content = ${JSON.stringify(content)}`);
    return content;
  }

  private static addSeparator(value: string | undefined): string {
    return value ? value + SEPARATOR : '';
  }

  private static genMmpIds(mmpIds: string[]) {
    let result: string = '';
    for (let mmpId of mmpIds) {
      if (mmpId) {
        result += SignUtil.addSeparator(mmpId);
      }
    }
    return result;
  }

  public static getSign(context: UIContext, content: string, privateKey: string): Promise<string> {
    return new Promise<string>((resolve) => {
      AegRsaSign.ohAegSignRSAWithPSSTextBase64(content, privateKey).then(async (sign: string) => {
        hilog.info(0, TAG, 'getSign success.');
        resolve(sign);
      }).catch((error: BusinessError) => {
        hilog.error(0, TAG, `getSign failed. code is ${error.code}, message is ${error.message}`);
        let msg: string | undefined =
          context.getHostContext()?.resourceManager.getStringSync($r('app.string.gen_sign_failed').id);
        if (msg) {
          context.getPromptAction().showToast({
            message: msg
          })
        }
      });
    })
  }
}