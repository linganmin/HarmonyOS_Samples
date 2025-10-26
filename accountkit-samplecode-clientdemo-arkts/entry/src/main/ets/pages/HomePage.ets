/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display } from '@kit.ArkUI';
import { authentication, minorsProtection } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { getUnionID } from '../common/Utils';
import { QuickLoginPage } from './QuickLoginPage';
import { OtherLoginPage } from './OtherLoginPage';
import { PersonalInfoPage } from './PersonalInfoPage';
import { ProtocolWebView } from './ProtocolWebView';
import { PrepareLoginPage } from './PrepareLoginPage';
import { UserInfo } from '../common/UserInfo';
import { ErrorCode } from '../common/ErrorCodeEntity';

const storage: LocalStorage = new LocalStorage();
// Persistently store the youth mode status of the app.
PersistentStorage.persistProp('minorsProtectionMode', false);
// Persistently store the screen time limit status of the app.
PersistentStorage.persistProp('availableTimeMode', true);
// Flag for disabling the app's youth mode separately.
PersistentStorage.persistProp('userTurnOffFlag', false);
// Uses persistently stored data to simulate silent sign-in.
PersistentStorage.persistProp('silentLoginMap', new Map<string, UserInfo>([]));
const logTag: string = 'HomePage';
const domainId: number = 0x0000;

@Entry(storage)
@Component
struct HomePage {
  pageInfos: NavPathStack = new NavPathStack();
  @LocalStorageLink('isLandScape') isLandScape: boolean = false;
  @LocalStorageLink('isPhone') isPhone: boolean = true;
  @LocalStorageLink('isPad') isPad: boolean = false;
  @LocalStorageLink('isBigDisplay') isBigDisplay: boolean = false;
  @LocalStorageLink('isDevice2in1') isDevice2in1: boolean = false;
  @LocalStorageLink('displayWidth') displayWidth: number = 0;
  @LocalStorageLink('isLogin') isLogin: boolean = false;
  @LocalStorageProp('isUserSelected') isUserSelected: boolean =
    false; // This parameter indicates whether the user selects other sign-in options.
  @StorageProp('silentLoginMap') silentLoginMap: Map<string, UserInfo> = new Map<string, UserInfo>([]);
  @StorageLink('minorsProtectionMode') minorsProtectionMode: boolean = false; // Youth mode status.
  @StorageLink('availableTimeMode') availableTimeMode: boolean = true; // Screen time limit status.
  /*
   * If the flag for disabling the app's youth mode separately is true,
   * this indicates that the user has disabled the youth mode in the app.
   * */
  @StorageLink('userTurnOffFlag') userTurnOffFlag: boolean = false;
  @StorageLink('lowerAge') lowerAge: number = -1; // Lower limit of the obtained age group.
  @StorageLink('upperAge') upperAge: number = -1; // Upper limit of the obtained age group.
  @StorageLink('unionID') unionID?: string = undefined;
  @StorageLink('showMinorsProtectionItem') showMinorsProtectionItem: boolean =
    true; // Determine whether to show the entry to youth mode settings.

  aboutToAppear() {
    hilog.info(domainId, logTag, 'HomePage aboutToAppear');
    // Call getMinorsProtectionInfoSync to query the youth mode status in the aboutToAppear lifecycle.
    this.getMinorsProtectionInfoSync();

    // Listen to userLogin events.
    this.getUIContext().getHostContext()?.eventHub.on('userLogin', () => {
      if (!this.isLogin) {
        this.changeUnionID();
        hilog.info(domainId, logTag, `isUserSelected: ${this.isUserSelected.toString()}`);
        if (this.getCurrentPageName() === 'OtherLoginPage' && !this.isUserSelected) {
          this.pageInfos?.replacePathByName('QuickLoginPage', null, false);
        }
      }
    });
    hilog.info(domainId, logTag, 'userLogin: on');

    // Listen to userLogout events.
    this.getUIContext().getHostContext()?.eventHub.on('userLogout', () => {
      if (!this.isLogin) {
        if (this.getCurrentPageName() === 'QuickLoginPage') {
          this.pageInfos?.replacePathByName('OtherLoginPage', null, false);
        }
      }
    });
    hilog.info(domainId, logTag, 'userLogin: on');
  }

  aboutToDisappear() {
    // Cancel listening to userLogin events.
    this.getUIContext().getHostContext()?.eventHub.off('userLogin');
    hilog.info(domainId, logTag, 'userLogin: off');
    // Cancel listening to userLogout events.
    this.getUIContext().getHostContext()?.eventHub.off('userLogout');
    hilog.info(domainId, logTag, 'userLogout: off');
  }

  private async changeUnionID() {
    // Save the UnionID.
    try {
      this.unionID = await getUnionID(this.getUIContext().getHostContext());
    } catch (error) {
      this.unionID = '';
      hilog.error(domainId, logTag, `Failed to authorize, errorCode: ${error.code}, errorMsg: ${error.message}`);
    }
    this.setUserInfo(this.unionID);
  }

  // Obtain information about the youth mode.
  private getMinorsProtectionInfoSync() {
    if (canIUse('SystemCapability.AuthenticationServices.HuaweiID.MinorsProtection')) {
      // Check whether the current device supports the youth mode.
      try {
        if (!minorsProtection.supportMinorsMode()) {
          hilog.info(domainId, logTag,
            'The current device environment does not support the youth mode, please check the current device environment.');
          return;
        }

        // Call getMinorsProtectionInfoSync to query the youth mode status.
        const minorsProtectionInfo: minorsProtection.MinorsProtectionInfo =
          minorsProtection.getMinorsProtectionInfoSync();
        // Obtain the youth mode status.
        const minorsProtectionMode: boolean = minorsProtectionInfo.minorsProtectionMode;
        hilog.info(domainId, logTag, `Succeeded in getting minorsProtectionMode is: ${minorsProtectionMode}`);
        this.minorsProtectionMode = minorsProtectionInfo.minorsProtectionMode;
        // The youth mode has been enabled. Obtain the age group information.
        if (minorsProtectionMode) {
          const ageGroup: minorsProtection.AgeGroup | undefined = minorsProtectionInfo.ageGroup;
          if (ageGroup) {
            this.lowerAge = ageGroup.lowerAge;
            this.upperAge = ageGroup.upperAge;
            hilog.info(domainId, logTag, `Succeeded in getting lowerAge is: ${ageGroup.lowerAge}`);
            hilog.info(domainId, logTag, `Succeeded in getting upperAge is: ${ageGroup.upperAge}`);
          }
        } else {
          /*
           * The youth mode is not enabled on the device.
           * It is recommended that the app follow the youth mode status on the device
           * and display all content without age restrictions.
           * The device's youth mode is disabled. Set the flag for disabling the app's youth mode separately to false.
           * Then, the app will follow the device's youth mode status.
           * */
          this.userTurnOffFlag = false;
        }
      } catch (error) {
        hilog.error(domainId, logTag,
          `Failed to invoke supportMinorsMode or getMinorsProtectionInfoSync. errCode: ${error.code}, message: ${error.message}`);
      }
    } else {
      hilog.info(domainId, logTag,
        'The current device does not support the invoking of the getMinorsProtectionInfoSync interface.');
    }
  }

  onPageShow(): void {
    hilog.info(domainId, logTag, `onPageShow`);
    this.showMinorsProtectionItem = this.checkMinorsProtectionSupportStatus();
  }

  // Check whether the current device supports the youth mode.
  private checkMinorsProtectionSupportStatus(): boolean {
    /*
     * Use the canIUse and supportMinorsMode APIs to check whether the device supports the youth mode.
     * If not, the youth mode entry will not be displayed.
     * */
    if (canIUse('SystemCapability.AuthenticationServices.HuaweiID.MinorsProtection')) {
      try {
        return minorsProtection.supportMinorsMode();
      } catch (error) {
        hilog.error(domainId, logTag,
          `Failed to invoke supportMinorsMode. errCode: ${error.code}, message: ${error.message}`);
      }
    }
    return false;
  }

  onBackPress(): boolean | void {
    hilog.info(domainId, logTag, 'HomePage onBackPress');
    return true;
  }

  // Update the screen information.
  private setDeviceDisplayData() {
    const CHECK_PHONE: number = 600;
    const CHECK_BIG_DISPLAY: number = 1000;
    const CHECK_DEVICE2IN1: number = 1640;

    try {
      const displayObj: display.Display = display.getDefaultDisplaySync();
      const orientation: display.Orientation = displayObj.orientation;
      const width: number = this.getUIContext().px2vp(displayObj.width);
      const height: number = this.getUIContext().px2vp(displayObj.height);
      this.displayWidth = width;
      this.isLandScape =
        orientation === display.Orientation.LANDSCAPE || orientation === display.Orientation.LANDSCAPE_INVERTED;
      this.isPhone = width < CHECK_PHONE || height < CHECK_PHONE;
      this.isBigDisplay = width > CHECK_BIG_DISPLAY;
      this.isDevice2in1 = width >= CHECK_DEVICE2IN1;
      this.isPad = width > CHECK_BIG_DISPLAY && width < CHECK_DEVICE2IN1 ||
        height > CHECK_BIG_DISPLAY && height < CHECK_DEVICE2IN1;
    } catch (error) {
      hilog.error(domainId, logTag,
        `Failed to obtain the default display object. Code: ${error?.code}, message: ${error?.message}`);
    }
  }

  // Read user information from persistently stored data and write it to localStorage.
  private setUserInfo(unionID: string) {
    if (this.silentLoginMap.has(unionID)) {
      const userInfo = this.silentLoginMap.get(unionID) as UserInfo;
      storage.setOrCreate('isSilentLogin', userInfo.isSilentLogin);
    } else {
      const userInfo: UserInfo = { isSilentLogin: false };
      this.silentLoginMap.set(unionID, userInfo);
      storage.setOrCreate('isSilentLogin', false);
    }
  }

  getCurrentPageName(): string {
    const allPathName = this.pageInfos.getAllPathName();
    return allPathName[allPathName.length - 1];
  }

  // Silent sign-in.
  silentLogin() {
    // Create a sign-in request and set parameters.
    const loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
    /*
     * false: If the user has not signed in to the HUAWEI ID, the HUAWEI ID sign-in screen will not be displayed.
     * Instead, error code 1001502001 will be returned.
     * */
    loginRequest.forceLogin = false;
    // Used to prevent cross-site request forgery.
    loginRequest.state = util.generateRandomUUID();
    // Execute the sign-in request.
    try {
      const controller = new authentication.AuthenticationController();
      controller.executeRequest(loginRequest).then((response: authentication.LoginWithHuaweiIDResponse) => {
        const loginWithHuaweiIDResponse = response as authentication.LoginWithHuaweiIDResponse;
        const state = loginWithHuaweiIDResponse.state;
        if (state && loginRequest.state !== state) {
          hilog.error(domainId, logTag, `Failed to login. The state is different, response state: ${state}`);
          return;
        }
        hilog.info(domainId, logTag, 'Succeeded in logging in.');
        const loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data!;
        const code = loginWithHuaweiIDCredential.authorizationCode;
        const unionID = loginWithHuaweiIDCredential.unionID;

        // Process code.
        // ...

        // Read necessary information from persistently stored data and save it to LocalStorage.
        const userInfo = this.silentLoginMap.get(unionID) as UserInfo;
        this.isLogin = true;
        storage.setOrCreate('avatar', userInfo.avatar);
        storage.setOrCreate('nickName', userInfo.nickName);
        storage.setOrCreate('quickLoginAnonymousPhone', userInfo.quickLoginAnonymousPhone);
      }).catch((error: BusinessError) => {
        this.dealAllError(error);
      })
    } catch (error) {
      this.dealAllError(error);
    }
  }

  // Handle the error.
  dealAllError(error: BusinessError): void {
    hilog.error(domainId, logTag, `Failed to login, errorCode: ${error.code}, errorMsg: ${error.message}`);
    /*
     * In app sign-in scenarios involving UI interactions,
     * it is recommended to guide users with the following error code prompts:
     * */
    if (error.code === ErrorCode.ERROR_CODE_LOGIN_OUT) {
      /*
       * The user has not signed in with a HUAWEI ID.
       * Use a HUAWEI ID to sign in and try again, or sign in to the app in another way.
       * */
    } else if (error.code === ErrorCode.AUTHENTICATION_NETWORK_ERROR) {
      // Network exception. Check the current network status and try again, or sign in to the app in another way.
    } else if (error.code === ErrorCode.ERROR_CODE_INTERNAL_ERROR) {
      // Sign-in failed. Try another sign-in option.
    } else if (error.code === ErrorCode.ERROR_CODE_USER_CANCEL) {
      // The user cancels the authorization.
    } else if (error.code === ErrorCode.ERROR_CODE_SYSTEM_SERVICE) {
      // System service exception. Try again later or sign in to the app in another way.
    } else if (error.code === ErrorCode.ERROR_CODE_REQUEST_REFUSE) {
      // Repeated request. No further action is needed.
    } else {
      // Sign-in failed. Try another sign-in option.
    }
  }

  @Builder
  PageMap(name: string, params?: Record<string, Object>) {
    if (name === 'PrepareLoginPage') {
      PrepareLoginPage({
        loginData: params,
        pageInfos: this.pageInfos
      })
    } else if (name === 'QuickLoginPage') {
      QuickLoginPage({
        params: params,
        pageInfos: this.pageInfos
      })
    } else if (name === 'OtherLoginPage') {
      OtherLoginPage({
        params: params,
        pageInfos: this.pageInfos
      })
    } else if (name === 'PersonalInfoPage') {
      PersonalInfoPage({
        pageInfos: this.pageInfos
      })
    } else if (name === 'ProtocolWebView') {
      ProtocolWebView({
        params: params,
        pageInfos: this.pageInfos
      })
    }
  }

  build() {
    Navigation(this.pageInfos) {
    }
    .onSizeChange(() => {
      this.setDeviceDisplayData();
    })
    .onAppear(async () => {
      await this.changeUnionID();
      // Uses persistently stored data to simulate silent sign-in.
      const userInfo = this.silentLoginMap.get(this.unionID as string) as UserInfo;
      // If the user has selected silent sign-in:
      if (userInfo?.isSilentLogin) {
        this.silentLogin();
      }
      this.pageInfos.pushPathByName('PrepareLoginPage', null, false);
    })
    .titleMode(NavigationTitleMode.Full)
    .hideTitleBar(true)
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.PageMap)
  }
}
