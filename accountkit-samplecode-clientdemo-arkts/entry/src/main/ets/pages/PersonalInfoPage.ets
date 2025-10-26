/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { shippingAddress } from '@kit.AccountKit';
import { UserInfo } from '../common/UserInfo';
import { AvoidRepeatClick } from '../common/AvoidRepeatClick';
import { AvatarAndNickname } from '../components/AvatarAndNickname';
import { Phone } from '../components/Phone';
import { Address } from '../components/Address';
import { InvoiceTitle } from '../components/InvoiceTitle';
import { MinorsProtection } from '../components/MinorsProtection';
import { SilentlyLoginSwitch } from '../components/SilentlyLoginSwitch';
import { getWhiteSpaceWidthByDisplayWidth } from '../common/Utils';

const logTag: string = 'PersonalInfoPage';
const domainId: number = 0x0000;

const storage: LocalStorage = new LocalStorage();

@Component
export struct PersonalInfoPage {
  @LocalStorageLink('quickLoginAnonymousPhone') quickLoginAnonymousPhone?: string = '';
  @LocalStorageLink('isLogin') isLogin: boolean = false;
  @LocalStorageLink('avatar') avatar?: string = '';
  @LocalStorageLink('nickName') nickName?: string = '';
  @LocalStorageLink('isSilentLogin') isSilentLogin: boolean = false;
  @State address?: shippingAddress.AddressInfo = undefined;
  @State invoiceTitle?: string = '';
  @StorageLink('minorsProtectionMode') minorsProtectionMode: boolean = false; // Youth mode status.
  @StorageLink('availableTimeMode') availableTimeMode: boolean = true; // Screen time limit status.
  /*
   * If the flag for disabling the app's youth mode separately is true,
   * this indicates that the user has disabled the youth mode in the app.
   * */
  @StorageLink('userTurnOffFlag') userTurnOffFlag: boolean = false;
  @StorageLink('lowerAge') lowerAge: number = -1; // Lower limit of the obtained age group.
  @StorageLink('upperAge') upperAge: number = -1; // Upper limit of the obtained age group.
  pageInfos: NavPathStack = new NavPathStack();
  @StorageLink('silentLoginMap') silentLoginMap: Map<string, UserInfo> = new Map<string, UserInfo>();
  @LocalStorageProp('isLandScape') isLandScape: boolean = false;
  @LocalStorageProp('isPhone') isPhone: boolean = true;
  @LocalStorageProp('isBigDisplay') isBigDisplay: boolean = false;
  @LocalStorageProp('isDevice2in1') isDevice2in1: boolean = false;
  @LocalStorageProp('displayWidth') displayWidth: number = 0;
  @StorageProp('statusBarHeight') statusBarHeight: number = 0;
  @StorageLink('showMinorsProtectionItem') showMinorsProtectionItem: boolean =
    true; // Determines whether to show the entry to youth mode settings.
  @State isShowAddress: boolean = true;
  @State isShowInvoiceTitle: boolean = true;

  aboutToAppear() {
    hilog.info(domainId, logTag, 'aboutToAppear');
    this.address = storage.get<shippingAddress.AddressInfo>('address');
    this.invoiceTitle = storage.get<string>('invoiceTitle') ?? '';
    this.initView();
  }

  initView(): void {
    this.isShowAddress = canIUse('SystemCapability.AuthenticationServices.HuaweiID.ShippingAddress');
    this.isShowInvoiceTitle = canIUse('SystemCapability.HuaweiID.InvoiceAssistant');
  }

  onBackPress(): boolean | void {
    if (this.pageInfos && this.pageInfos.size() > 0) {
      this.pageInfos?.popToName('PrepareLoginPage', null, true);
      return true;
    }
  }

  // Update persistently stored data silentLoginMap.
  updateSilentLoginMap(unionID: string) {
    const userInfo: UserInfo = {
      avatar: this.avatar,
      nickName: this.nickName,
      quickLoginAnonymousPhone: storage.get('quickLoginAnonymousPhone') as string,
      isSilentLogin: this.isSilentLogin
    }
    this.silentLoginMap.set(unionID, userInfo);
  }

  // Sign out.
  logout() {
    // Change the sign-in status.
    this.isLogin = false;
    // Delete personal information from LocalStorage.
    this.quickLoginAnonymousPhone = undefined;
    this.avatar = undefined;
    this.nickName = undefined;
    // Return to PrepareLoginPage.
    this.pageInfos?.popToName('PrepareLoginPage', true);
  }

  build() {
    NavDestination() {
      Column() {
        // Page title and back button.
        Row() {
          Button({ type: ButtonType.Normal }) {
            Image($r('app.media.hwid_next_ic_appback'))
              .backgroundColor(Color.Transparent)
              .borderRadius(20)
              .width(40)
              .height(40)
              .draggable(false)
              .autoResize(false)
              .focusable(true)
              .fillColor($r('sys.color.ohos_id_color_titlebar_icon'))
              .matchTextDirection(true)
          }
          .alignSelf(ItemAlign.Start)
          .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
          .borderRadius(20)
          .width(40)
          .height(40)
          .margin({
            top: 8
          })
          .id('personalInfoBackPressButton')
          .onClick(() => {
            AvoidRepeatClick.avoidRepeatClick(() => {
              this.onBackPress();
            });
          })

          Text($r('app.string.personalInfo'))
            .fontSize($r('sys.float.ohos_id_text_size_headline8'))
            .fontWeight(FontWeight.Bold)
            .padding({ left: 8 })
        }.alignSelf(ItemAlign.Start)
        .height(56)
        .padding({
          left: getWhiteSpaceWidthByDisplayWidth(this.displayWidth),
          right: getWhiteSpaceWidthByDisplayWidth(this.displayWidth)
        })

        Scroll() {
          Column() {
            List({ space: 12 }) {
              ListItem({ style: ListItemStyle.CARD }) {
                // Avatar and nickname.
                AvatarAndNickname({
                  avatar: this.avatar,
                  nickName: this.nickName,
                  onChange: (unionID) => {
                    this.updateSilentLoginMap(unionID);
                  }
                })
              }
              .height(undefined)
              .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
              .borderRadius(20)
              .padding(0)

              ListItem({ style: ListItemStyle.CARD }) {
                // Mobile number.
                Phone({
                  quickLoginAnonymousPhone: this.quickLoginAnonymousPhone,
                  onChange: (unionID) => {
                    this.updateSilentLoginMap(unionID);
                  }
                })
              }
              .height(undefined)
              .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
              .borderRadius(20)
              .padding(0)

              if (this.isShowAddress) {
                ListItem({ style: ListItemStyle.CARD }) {
                  // Shipping address.
                  Address({
                    address: this.address
                  })
                }
                .height(undefined)
                .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
                .borderRadius(20)
                .padding(0)
              }

              if (this.isShowInvoiceTitle) {
                ListItem({ style: ListItemStyle.CARD }) {
                  // Invoice title.
                  InvoiceTitle({
                    invoiceTitle: this.invoiceTitle
                  })
                }
                .height(undefined)
                .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
                .borderRadius(20)
                .padding(0)
              }
            }
            .width('100%')
            .height('auto')
            .margin({ top: 16 })

            /*
             * Use the canIUse and supportMinorsMode APIs to check whether the device supports the youth mode. If not,
             * the youth mode entry will not be displayed.
             * */
            if (this.showMinorsProtectionItem) {
              // Youth mode.
              MinorsProtection({
                minorsProtectionMode: this.minorsProtectionMode,
                availableTimeMode: this.availableTimeMode,
                userTurnOffFlag: this.userTurnOffFlag,
                lowerAge: this.lowerAge,
                upperAge: this.upperAge
              })
            }

            // Silent sign-in switch.
            SilentlyLoginSwitch({
              isSilentLogin: this.isSilentLogin,
              onChange: (unionID) => {
                this.updateSilentLoginMap(unionID);
              }
            })

            Blank().layoutWeight(1)

            // Sign out.
            Row() {
              Button({ type: ButtonType.Capsule }) {
                Text($r('app.string.logout'))
                  .fontWeight(FontWeight.Medium)
              }
              .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
              .fontColor($r('app.color.activity_color'))
              .width('100%')
              .height(40)
              .constraintSize({
                maxWidth: 448
              })
              .id('logoutButton')
              .onClick(() => {
                AvoidRepeatClick.avoidRepeatClick(() => {
                  this.logout();
                });
              })
            }
            .padding({
              bottom: this.isDevice2in1 ? 12 : 44,
              top: 24
            })
            .offset({
              top: this.isLandScape && this.isPhone ? 0 : (this.isDevice2in1 ? -106 : -56)
            })
            .margin({ top: this.isDevice2in1 ? 106 : 56 })
          }
        }
        .padding({
          left: getWhiteSpaceWidthByDisplayWidth(this.displayWidth),
          right: getWhiteSpaceWidthByDisplayWidth(this.displayWidth),
          bottom: this.isLandScape && this.isPhone ? 56 : 0
        })
      }
      .padding({
        // There is no need to avoid the top status bar when the device is a phone in landscape mode or 2-in-1 device.
        top: this.isLandScape && this.isPhone || this.isDevice2in1 ? 0 : this.getUIContext().px2vp(this.statusBarHeight)
      })
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))

    }.hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
  }
}
