/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { UserInfo } from '../common/UserInfo';
import { Avatar } from '../components/Avatar';
import { Phone } from '../components/Phone';
import { Address } from '../components/Address';
import { InvoiceTitle } from '../components/InvoiceTitle';
import { MinorsProtection } from '../components/MinorsProtection';

const logTag: string = 'PersonalInfoPage';
const domainId: number = 0x0000;

@Component
export struct PersonalInfoPage {
  @StorageLink('userInfo') @Watch('updateSilentLoginMap') userInfo: UserInfo = {};
  @StorageLink('silentLoginMap') silentLoginMap: Map<string, UserInfo> = new Map<string, UserInfo>([]);
  @StorageLink('minorsProtectionMode') minorsProtectionMode: boolean = false; // Youth mode status.
  @StorageLink('availableTimeMode') availableTimeMode: boolean = true; // Screen time limit status.
  /*
   * If the flag for disabling the atomic service's youth mode separately is true,
   * this indicates that the user has disabled the youth mode in the atomic service.
   * */
  @StorageLink('userTurnOffFlag') userTurnOffFlag: boolean = false;
  @StorageLink('lowerAge') lowerAge: number = -1; // Lower limit of the obtained age group.
  @StorageLink('upperAge') upperAge: number = -1; // Upper limit of the obtained age group.
  @Prop mainBoxPadding: number;
  @StorageLink('showMinorsProtectionItem') showMinorsProtectionItem: boolean =
    true; // Determine whether to show the entry to youth mode settings.
  @State avatar: string = '';

  // Update persistently stored data silentLoginMap.
  updateSilentLoginMap() {
    const unionID = AppStorage.get('currentUser') as string;
    this.silentLoginMap.set(unionID, this.userInfo);
  }

  // Check whether user information is stored in userInfo.
  private hasCache(): boolean {
    return this.userInfo.address !== undefined ||
      this.userInfo.invoiceTitle !== undefined ||
      this.userInfo.phone !== undefined ||
      this.userInfo.avatar !== undefined;
  }

  // Remove the association.
  private disassociate() {
    // Delete personal information from AppStorage.
    this.userInfo = {};
    this.avatar = '';
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          // Avatar.
          Avatar({
            avatar: this.avatar,
            onChange: (avatar) => {
              hilog.info(domainId, logTag, `Avatar has updated: ${avatar}`);
              this.userInfo.avatar = avatar;
            }
          })

          // Mobile number.
          Phone({
            phone: this.userInfo.phone,
            onChange: (phone) => {
              hilog.info(domainId, logTag, `Phone number has updated: ${phone}`);
              this.userInfo.phone = phone;
            }
          })

          // Shipping address.
          Address({
            address: this.userInfo.address,
            onChange: (address) => {
              hilog.info(domainId, logTag, `Address has updated`);
              this.userInfo.address = address;
            }
          })

          // Invoice title.
          InvoiceTitle({
            invoiceTitle: this.userInfo.invoiceTitle,
            onChange: (invoiceTitle) => {
              hilog.info(domainId, logTag, `InvoiceTitle has updated`);
              this.userInfo.invoiceTitle = invoiceTitle;
            }
          })

          // Youth mode switch.
          if (this.showMinorsProtectionItem) {
            MinorsProtection({
              minorsProtectionMode: this.minorsProtectionMode,
              availableTimeMode: this.availableTimeMode,
              userTurnOffFlag: this.userTurnOffFlag,
              lowerAge: this.lowerAge,
              upperAge: this.upperAge
            })
          }

          // Remove the association.
          Row() {
            Button({ stateEffect: this.hasCache() }) {
              Text($r('app.string.disassociate'))
                .fontWeight(FontWeight.Medium)
            }
            .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
            .fontColor($r('sys.color.warning'))
            .width('100%')
            .height(40)
            .opacity(this.hasCache() ? 1 : 0.4)
            .constraintSize({
              maxWidth: 448
            })
            .id('disassociateButton')
            .onClick(() => {
              this.disassociate();
            })
          }
          .padding({
            bottom: 8,
            top: 24
          })

          Row().layoutWeight(1)
        }
      }.padding({ left: this.mainBoxPadding, right: this.mainBoxPadding })
    }
    .alignItems(HorizontalAlign.Start)
  }
}