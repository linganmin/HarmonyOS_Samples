/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { authentication, minorsProtection } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { display } from '@kit.ArkUI';
import { UserInfo } from '../common/UserInfo';
import { PersonalInfoPage } from './PersonalInfoPage';
import { ShoppingPage } from './ShoppingPage';
import { ErrorCode } from '../common/ErrorCodeEntity';

const storage: LocalStorage = new LocalStorage();

// Uses persistently stored data to simulate silent sign-in.
PersistentStorage.persistProp('silentLoginMap', new Map<string, UserInfo>([]));
// Flag for disabling the atomic service's youth mode separately.
PersistentStorage.persistProp('userTurnOffFlag', false);

const logTag: string = 'Index';
const domainId: number = 0x0000;
const pageMap: Map<string, Resource> = new Map<string, Resource>([
  ['ShoppingPage', $r('app.string.shopping')],
  ['PersonalInfoPage', $r('app.string.my')]
]);
const CHECK_BIG_DISPLAY: number = 1000;
const CHECK_DEVICE2IN1: number = 1440;
const CHECK_PHONE: number = 600;

@Entry(storage)
@Component
struct Index {
  @State currentPage: 'ShoppingPage' | 'PersonalInfoPage' = 'ShoppingPage'; // Current screen.
  @StorageProp('silentLoginMap') silentLoginMap: Map<string, UserInfo> = new Map<string, UserInfo>([]);
  @StorageLink('minorsProtectionMode') minorsProtectionMode: boolean = false; // Youth mode status.
  /*
   * If the flag for disabling the atomic service's youth mode separately is true,
   * this indicates that the user has disabled the youth mode in the atomic service.
   * */
  @StorageLink('userTurnOffFlag') userTurnOffFlag: boolean = false;
  @StorageLink('lowerAge') lowerAge: number = -1; // Lower limit of the obtained age group.
  @StorageLink('upperAge') upperAge: number = -1; // Upper limit of the obtained age group.
  @StorageProp('statusBarHeight') statusBarHeight: number = 0;
  @LocalStorageLink('isLandScape') isLandScape: boolean = false;
  @LocalStorageLink('isPad') isPad: boolean = false;
  @LocalStorageLink('isPhone') isPhone: boolean = false;
  @LocalStorageLink('displayWidth') displayWidth: number = 0;
  @State mainBoxPadding: number = 0;
  @StorageLink('showMinorsProtectionItem') showMinorsProtectionItem: boolean =
    true; // Determine whether to show the entry to youth mode settings.

  aboutToAppear() {
    hilog.info(domainId, logTag, 'Index aboutToAppear');
    // Call getMinorsProtectionInfoSync to query the youth mode status in the aboutToAppear lifecycle.
    this.getMinorsProtectionInfoSync();
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
           * It is recommended that the atomic service follow the youth mode status on the device
           * and display all content without age restrictions.
           * The device's youth mode is disabled.
           * Set the flag for disabling the atomic service's youth mode separately to false.
           * Then, the atomic service will follow the device's youth mode status.
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
    this.silentLogin();
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

  // Silent sign-in.
  silentLogin() {
    // Execute the sign-in request.
    try {
      // Create a sign-in request and set parameters.
      const loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
      /*
       * false: If the user has not signed in to the HUAWEI ID,
       * the HUAWEI ID sign-in screen will not be displayed. Instead, error code 1001502001 will be returned.
       * */
      loginRequest.forceLogin = false;
      // Used to prevent cross-site request forgery. You are advised to assign a value to state as follows:
      loginRequest.state = util.generateRandomUUID();
      // Execute the sign-in request.
      const controller = new authentication.AuthenticationController();
      controller.executeRequest(loginRequest).then((response: authentication.LoginWithHuaweiIDResponse) => {
        const loginWithHuaweiIDResponse = response as authentication.LoginWithHuaweiIDResponse;
        const state = loginWithHuaweiIDResponse.state;
        if (state && loginRequest.state !== state) {
          hilog.error(domainId, logTag, `Failed to login. The state is different, response state: ${state}`);
          return;
        }
        const loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data!;
        const code = loginWithHuaweiIDCredential.authorizationCode;
        const unionID = loginWithHuaweiIDCredential.unionID;

        // Process code.
        // ...

        // Update the information about the currently signed-in user.
        AppStorage.setOrCreate('currentUser', unionID);
        if (this.silentLoginMap.has(unionID)) {
          /*
           * If the information about the current user is found in the persistently stored data,
           * obtain the information and store it in AppStorage.
           * */
          AppStorage.setOrCreate('userInfo', this.silentLoginMap.get(unionID)!);
        } else {
          // Create an empty object if the target is not found.
          AppStorage.setOrCreate('userInfo', {});
        }
      }).catch((error: BusinessError) => {
        this.dealAllError(error);
      })
    } catch (error) {
      this.dealAllError(error);
    }
  }

  // Update the screen information.
  private setDeviceDisplayData() {
    try {
      const displayObj: display.Display = display.getDefaultDisplaySync();
      const orientation: display.Orientation = displayObj.orientation;
      const width: number = this.getUIContext().px2vp(displayObj.width);
      const height: number = this.getUIContext().px2vp(displayObj.height);
      this.displayWidth = width;
      this.isPhone = width < CHECK_PHONE || height < CHECK_PHONE;
      this.isLandScape =
        orientation === display.Orientation.LANDSCAPE || orientation === display.Orientation.LANDSCAPE_INVERTED;
      this.isPad = width > CHECK_BIG_DISPLAY && width < CHECK_DEVICE2IN1;
    } catch (error) {
      hilog.error(domainId, logTag,
        `Failed to get the default display object. Code: ${error?.code}, message: ${error?.message}`);
    }
  }

  private getMainBoxPadding(): number {
    // Constant used to define page width and margins.
    const FIRST_DISPLAY_WIDTH: number = 400;
    const SECOND_DISPLAY_WIDTH: number = 800;
    // Padding used for screens of different widths.
    const FIRST_PADDING: number = 16;
    const SECOND_PADDING: number = 24;
    const THIRD_PADDING: number = 32;

    if (this.displayWidth <= FIRST_DISPLAY_WIDTH) {
      return FIRST_PADDING;
    } else if (this.displayWidth > FIRST_DISPLAY_WIDTH && this.displayWidth <= SECOND_DISPLAY_WIDTH) {
      return SECOND_PADDING;
    } else {
      return THIRD_PADDING;
    }
  }

  @Builder
  NavBar() {
    Flex({
      direction: this.isLandScape && this.isPad ? FlexDirection.Column : FlexDirection.Row,
      justifyContent: this.isLandScape && this.isPad ? FlexAlign.Center : FlexAlign.SpaceAround
    }) {
      this.Unit('ShoppingPage')
      this.Unit('PersonalInfoPage')
    }
    .shadow({
      type: ShadowType.COLOR,
      color: '#ff807b7b',
      offsetX: 0,
      offsetY: 0,
      fill: true
    } as ShadowOptions)
    .width(this.isLandScape && this.isPad ? 96 : '100%')
    .height(this.isLandScape && this.isPad ? '100%' : 80)
    .alignSelf(ItemAlign.Center)
    .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
  }

  @Builder
  Unit(routerName: 'ShoppingPage' | 'PersonalInfoPage') {
    Column() {
      Image(this.currentPage === routerName ? $r('app.media.ic_me') : $r('app.media.ic_me_normal'))
        .width(21)
        .height(21)
        .borderRadius(12)
        .opacity(this.currentPage === routerName ? 1 : 0.6)
        .draggable(false)
      Text('Tab')
        .fontSize(10)
        .lineHeight(13)
        .fontColor(this.currentPage === routerName ?
          $r('app.color.activity_color') : $r('sys.color.ohos_id_color_text_secondary'))
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Center)
    }
    .alignItems(HorizontalAlign.Center)
    .width(this.isLandScape && this.isPad ? '100%' : '25%')
    .height(this.isLandScape && this.isPad ? 200 : 52)
    .justifyContent(FlexAlign.Center)
    .padding({
      top: 5,
      bottom: 5
    })
    .id('unit' + routerName)
    .onClick(() => {
      this.currentPage = routerName;
    })
  }

  build() {
    Flex({
      direction: this.isLandScape && this.isPad ? FlexDirection.RowReverse : FlexDirection.Column,
      justifyContent: FlexAlign.SpaceAround
    }) {
      Column() {
        Row() {
          Text(pageMap.get(this.currentPage))
            .fontSize(28)
            .lineHeight(36)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .height(36)
        .margin({ top: 10, bottom: 10 })
        .padding({ left: this.mainBoxPadding, right: this.mainBoxPadding })

        Row() {
          if (this.currentPage === 'PersonalInfoPage') {
            PersonalInfoPage({ mainBoxPadding: this.mainBoxPadding });
          } else {
            ShoppingPage({ mainBoxPadding: this.mainBoxPadding });
          }
        }
        .layoutWeight(1)
        .padding({ bottom: this.isLandScape && this.isPad ? 34 : 0 })
      }.layoutWeight(1)

      Row() {
        this.NavBar();
      }
    }
    .padding({ top: this.isLandScape && this.isPhone ? 0 : this.getUIContext().px2vp(this.statusBarHeight) })
    .onSizeChange(() => {
      this.setDeviceDisplayData();
      this.mainBoxPadding = this.getMainBoxPadding();
    })
    .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
  }
}