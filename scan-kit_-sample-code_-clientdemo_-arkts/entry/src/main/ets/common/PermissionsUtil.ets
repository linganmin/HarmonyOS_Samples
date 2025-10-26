import { bundleManager, common, abilityAccessCtrl, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import Logger from './Logger';
import { UIContextSelf } from '../pages/customScan/model/UIContextSelf';

const TAG = 'Scan SampleCode PermissionsUtil';
let context = UIContextSelf.getHostContext() as common.UIAbilityContext;

export class PermissionsUtil {
  public static async checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let atManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;
    // Obtain accessTokenId of the app.
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      Logger.error(TAG, `Failed to get bundle info for self. Code: ${error?.code}.`);
    }
    //  Check whether the app has the required permission.
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      Logger.error(TAG, `Failed to check access token. Code: ${error?.code}.`);
    }
    return grantStatus;
  }

  public static async reqPermissionsFromUser(): Promise<number[]> {
    Logger.info(TAG, 'reqPermissionsFromUser start ');
    let atManager = abilityAccessCtrl.createAtManager();
    let grantStatus: PermissionRequestResult = { permissions: [], authResults: [] }
    try {
      grantStatus = await atManager.requestPermissionsFromUser(context, ['ohos.permission.CAMERA']);
    } catch (error) {
      Logger.error(TAG, `Failed to request permissions from user. Code: ${error?.code}.`);
    }
    return grantStatus.authResults;
  }
}
