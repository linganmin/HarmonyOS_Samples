import { util } from '@kit.ArkTS';
import {
  FunctionalButton,
  functionalButtonComponentManager,
  FunctionalInput,
  functionalInputComponentManager
} from '@kit.ScenarioFusionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { abilityAccessCtrl, common, PermissionRequestResult } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  ButtonModifier,
  LoadingProgressModifier,
  SymbolGlyphModifier,
  TextInputModifier,
  TextModifier
} from '@kit.ArkUI';

@Observed
class ComponentsInfo {
  key: string = util.generateRandomUUID(true);
  index: number;
  name: string;
  icon: Resource;
  flag: boolean;
  change: boolean;

  constructor(index: number, name: string, icon: Resource, flag = false, change = false) {
    this.index = index;
    this.name = name;
    this.icon = icon;
    this.flag = flag;
    this.change = change;
  }
}

class DividerTmp {
  strokeWidth: Length = 1;
  startMargin: Length = 60;
  endMargin: Length = 10;
  color: ResourceColor = '#ffe9f0f0';

  constructor(strokeWidth: Length, startMargin: Length, endMargin: Length, color: ResourceColor) {
    this.strokeWidth = strokeWidth;
    this.startMargin = startMargin;
    this.endMargin = endMargin;
    this.color = color;
  }
}

@Component
struct listComponent {
  @ObjectLink itemComponent: ComponentsInfo;
  @Link components: ComponentsInfo[];
  @State arrow_right: Resource = $r('app.media.arrow_right');
  @State arrow_down: Resource = $r('app.media.arrow_down');
  private maxIndex: number = this.components.length - 1;

  build() {
    ListItemGroup() {
      ListItem() {
        List() {
          ListItem() {
            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              Text(this.itemComponent.name)
                .fontSize('54px')
                .fontWeight(500)
                .lineHeight('88px')
                .letterSpacing('0px')
                .textAlign(TextAlign.Start)
                .fontColor('rgba(0, 0, 0, 0.9)')
                .margin({ top: 3 })
              if (!this.itemComponent.flag) {
                Image(this.arrow_right)
                  .width('38px')
                  .height('104px')
                  .margin({
                    right: 30
                  })
              } else {
                Image(this.arrow_down)
                  .width('104px')
                  .height('38px')
                  .margin({
                    right: 30,
                    top: 10
                  })
              }
            }
            .width('100%')
            .margin(12)
          }
        }
        .backgroundColor('rgb(255, 255, 255)')
        .borderRadius(
          this.itemComponent.index === 0 && this.itemComponent.index === this.maxIndex ? {
            topLeft: 20,
            topRight: 20,
            bottomLeft: 20,
            bottomRight: 20
          } :
            this.itemComponent.index === 0 && !this.components[this.itemComponent.index].flag ?
              { topLeft: 20, topRight: 20 } :
              this.itemComponent.index === 0 && this.components[this.itemComponent.index].flag ? {
                topLeft: 20,
                topRight: 20,
                bottomLeft: 20,
                bottomRight: 20
              } :
                this.itemComponent.index === this.maxIndex && !this.components[this.itemComponent.index - 1].flag ?
                  { bottomLeft: 20, bottomRight: 20 } :
                  this.itemComponent.index === this.maxIndex && this.components[this.itemComponent.index - 1].flag ? {
                    topLeft: 20,
                    topRight: 20,
                    bottomLeft: 20,
                    bottomRight: 20
                  } :
                    !this.components[this.itemComponent.index - 1].flag &&
                    this.components[this.itemComponent.index].flag ? { bottomLeft: 20, bottomRight: 20 } :
                      this.components[this.itemComponent.index - 1].flag &&
                        !this.components[this.itemComponent.index].flag ? { topLeft: 20, topRight: 20 } :
                        this.components[this.itemComponent.index - 1].flag &&
                        this.components[this.itemComponent.index].flag ? {
                          topLeft: 20,
                          topRight: 20,
                          bottomLeft: 20,
                          bottomRight: 20
                        } : 0
        )
        .onClick(() => {
          this.itemComponent.flag = !this.itemComponent.flag;
          if (!(this.itemComponent.index === this.maxIndex)) {
            this.components[this.itemComponent.index + 1].change =
              !this.components[this.itemComponent.index + 1].change;
          }
        })
      }

      if (this.itemComponent.flag) {
        if (this.itemComponent.name === 'Button set style') {
          ButtonComponent({ name: this.itemComponent.name })
        } else {
          ButtonComponent({ name: this.itemComponent.name })
            .margin({ top: 16, bottom: 24 })
        }
      }
    }
  }
}

@Component
struct lists {
  @Link components: ComponentsInfo[];
  @State listDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0');

  build() {
    Column() {
      List() {
        ForEach(this.components, (item: ComponentsInfo) => {
          listComponent({ itemComponent: item, components: this.components })
        }, (item: ComponentsInfo) => JSON.stringify(item))
      }
      .width('100%')
      .margin({ top: 6 })
      .padding({ left: 20, right: 20 })
      .divider(this.listDivider)
    }
  }
}

@Component
struct TextComponent {
  @Prop textInfo: string;

  build() {
    Text(this.textInfo)
      .fontFamily('HarmonyOS Sans')
      .fontColor('rgba(0, 0, 0, 0.6)')
      .fontSize('60px')
      .fontWeight(500)
      .lineHeight('96px')
      .letterSpacing('0px')
      .textAlign(TextAlign.Start)
      .width('100%')
      .margin({
        top: 18,
        bottom: 8
      })
      .padding({ left: 20 })
  }
}

@Component
struct ButtonComponent {
  @Prop name: string;
  @State url: ResourceStr = $r('app.media.account');
  @State inputContent: string = '';

  @Builder
  QuicklyVerifyTheMobileNumberScenario() {
    FunctionalButton({
      params: {
        openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
        label: 'Verify mobile number quickly', styleOption: {
          styleConfig: new functionalButtonComponentManager.ButtonConfig().align(Alignment.Center)
        },
      },
      controller: new functionalButtonComponentManager.FunctionalButtonController()
        .onGetPhoneNumber((err, data) => {
          if (err) {
            hilog.error(0x0000, "testTag", "error： %{public}d %{public}s", err.code, err.message);
            return;
          }
          let code = data.code;
          hilog.info(0x0000, "testTag", "succeeded in authenticating");
        })
    })
  }

  @Builder
  OpenTheAppScenario() {
    FunctionalButton({
      params: {
        openType: functionalButtonComponentManager.OpenType.LAUNCH_APP,
        label: 'Open APP',
        appParam: {
          bundleName: 'xxx',
          abilityName: 'xxx'
        },
      },
      controller: new functionalButtonComponentManager.FunctionalButtonController()
        .onLaunchApp((err, data) => {
          if (err) {
            hilog.error(0x0000, "testTag", "error： %{public}d %{public}s", err.code, err.message);
            return;
          }
          hilog.info(0x0000, "testTag", "succeeded in launching app");
        })
    })
  }

  @Builder
  ChooseAddressScenario() {
    FunctionalButton({
      params: {
        openType: functionalButtonComponentManager.OpenType.CHOOSE_ADDRESS,
        label: 'Select shipping address',
      },
      controller: new functionalButtonComponentManager.FunctionalButtonController()
        .onChooseAddress((err, data) => {
          if (err) {
            hilog.error(0x0000, "testTag", "error： %{public}d %{public}s", err.code, err.message);
            return;
          }
          let userName: string = data.userName;
          let mobileNumber: string = data.mobileNumber as string;
          let countryCode: string = data.countryCode as string;
          let provinceName: string = data.provinceName as string;
          let cityName: string = data.cityName as string;
          let districtName: string = data.districtName as string;
          let streetName: string = data.streetName as string;
          let detailedAddress: string = data.detailedAddress;
          hilog.info(0x0000, "testTag", "succeeded in choosing address");
        })
    })
  }

  @Builder
  ChooseInvoiceTitleScenario() {
    FunctionalButton({
      params: {
        openType: functionalButtonComponentManager.OpenType.CHOOSE_INVOICE_TITLE,
        label: 'Select invoice title',
      },
      controller: new functionalButtonComponentManager.FunctionalButtonController()
        .onChooseInvoiceTitle((err, data) => {
          if (err) {
            hilog.error(0x0000, "testTag", "error： %{public}d %{public}s", err.code, err.message);
            return;
          }
          let type: string = data.type;
          let title: string = data.title;
          let taxNumber: string = data.taxNumber;
          let companyAddress: string | undefined = data.companyAddress;
          let telephone: string | undefined = data.telephone;
          let bankName: string | undefined = data.bankName;
          let bankAccount: string | undefined = data.bankAccount;
          hilog.info(0x0000, "testTag", "succeeded in choosing invoice title");
        })
    })
  }

  @Builder
  ChooseLocationScenario() {
    FunctionalButton({
      params: {
        openType: functionalButtonComponentManager.OpenType.CHOOSE_LOCATION,
        label: 'Select map location',
      },
      controller: new functionalButtonComponentManager.FunctionalButtonController()
        .onChooseLocation((err, data) => {
          if (err) {
            hilog.error(0x0000, "testTag", "error： %{public}d %{public}s", err.code, err.message);
            return;
          }
          let name: string = data.name;
          let address: string = data.address;
          let longitude: number = data.longitude;
          let latitude: number = data.latitude;
          hilog.info(0x0000, "testTag", "succeeded in choosing location");
        })
    })
  }

  @Builder
  ChooseAvatarScenario() {
    FunctionalButton({
      params: {
        openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR, label: '', styleOption: {
          styleConfig:
          new functionalButtonComponentManager.ButtonConfig()
            .type(ButtonType.Normal)
            .backgroundImage(this.url)
            .backgroundImageSize(ImageSize.Cover)
            .width(50)
            .height(50)
            .backgroundColor('#F1F3F5')
        },
      },
      controller: new functionalButtonComponentManager.FunctionalButtonController()
        .onChooseAvatar((err, data) => {
          if (err) {
            hilog.error(0x0000, "testTag", "error： %{public}d %{public}s", err.code, err.message);
            return;
          }
          hilog.info(0x0000, "testTag", "succeeded in choosing avatar");
          this.url = data.avatarUri ?? this.url;
        })
    })
  }

  @Builder
  SelectDistrictScenario() {
    FunctionalInput({
      params: {
        // InputType. SELECT_DISTRICT indicates that the input type is the province/city selector type.
        inputType: functionalInputComponentManager.InputType.SELECT_DISTRICT,
        textInputValue: {
          text: this.inputContent,
          placeholder: 'Province, city, district, street',
        },
        // Adjust the TextInput style.
        inputAttributeModifier: new TextInputModifier()
          .fontColor($r('sys.color.ohos_id_color_badge_red'))
          .onChange((value) => {
            if (value !== this.inputContent) {
              this.inputContent = value;
            }
          }),
        // Set the icon at the end.
        icon: $r('sys.symbol.xmark'),
        // Set the event and style of the symbol icon.
        iconSymbolModifier: new SymbolGlyphModifier()
          .onClick(() => {
            this.inputContent = '';
          })
          .fontSize(32),
      },
      // When InputType is set to SELECT_DISTRICT, the callback must be onSelectDistrict.
      controller: new functionalInputComponentManager.FunctionalInputController().onSelectDistrict((err,
        data: functionalInputComponentManager.DistrictSelectResult) => {
        if (err) {
          // Error processing.
          hilog.error(0x0000, "testTag", "error: %{public}d %{public}s", err.code, err.message);
          return;
        }
        // Success processing.
        hilog.info(0x0000, "testTag", "succeeded in selecting district");
        // Display the selected region information in the input component.
        this.inputContent = data.inputContent;
      })
    })
  }

  @Builder
  PermissionSettingScenario() {
    Column({ space: 3 }) {
      // Call the requestPermissionsFromUser button component.
      Button('Request user authorization')
        .onClick(() => {
          let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
          let context: Context = this.getUIContext().getHostContext() as common.UIAbilityContext;
          try {
            // Add the ohos.permission.READ_CALENDAR, ohos.permission.WRITE_CALENDAR permission to the module.json5 file.
            atManager.requestPermissionsFromUser(context,
              ['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR'],
              (err: BusinessError, data: PermissionRequestResult) => {
                if (err) {
                  hilog.error(0x0000, "testTag", "failed in requesting Permissions from user : %{public}d %{public}s",
                    err.code, err.message);
                } else {
                  hilog.info(0x0000, "testTag", 'data permissions: %{public}s', data.permissions?.join(','));
                  hilog.info(0x0000, "testTag", 'data authResults: %{public}s', data.authResults?.join(','));
                  hilog.info(0x0000, "testTag", 'data dialogShownResults: %{public}s',
                    data.dialogShownResults?.join(','));
                }
              })
          } catch (err) {
            hilog.error(0x0000, "testTag", "error： %{public}d %{public}s", err.code, err.message);
          }
        })

      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.PERMISSION_SETTING,
          label: 'Setting permissions',
          permissionListParam: ['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR'],
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController()
          .onPermissionSetting((err, data) => {
            if (err) {
              hilog.error(0x0000, "testTag", "error： %{public}d %{public}s", err.code, err.message);
              return;
            }
            let result = data.permissionResult;
            result.forEach(res => {
              hilog.info(0x0000, "testTag", "data: %{public}s", String(res));
            })
          })
      })
    }.alignItems(HorizontalAlign.Start)
  }

  @Builder
  StyleConfiguration() {
    Flex({ direction: FlexDirection.Row }) {
      SquareButtonComponent({ name: 'Style 1', backGroundColor: 'rgb(10, 89, 247)' })
      SquareButtonComponent({ name: 'Style 2', backGroundColor: 'rgb(141, 84, 239)' })
      ButtonInModifier({ name: 'Style 3', backGroundColor: 'rgb(253, 183, 68)' })
    }
  }

  build() {
    Row() {
      if ('Verify mobile number quickly Button scenario' === this.name) {
        this.QuicklyVerifyTheMobileNumberScenario()
      }
      if ('Open APP Button scenario' === this.name) {
        this.OpenTheAppScenario()
      }
      if ('Select shipping address Button scenario' === this.name) {
        this.ChooseAddressScenario()
      }
      if ('Select invoice title Button scenario' === this.name) {
        this.ChooseInvoiceTitleScenario()
      }
      if ('Select map location Button scenario' === this.name) {
        this.ChooseLocationScenario()
      }
      if ('Choose avatar Button scenario' === this.name) {
        this.ChooseAvatarScenario()
      }
      if ('Province/City/District Selector Input scenario' === this.name) {
        this.SelectDistrictScenario()
      }
      if ('Button Set style' === this.name) {
        this.StyleConfiguration()
      }
      if ('Setting Permissions Button scenario' === this.name) {
        this.PermissionSettingScenario()
      }
    }
  }
}

@Component
struct SquareButtonComponent {
  @Prop name: string;
  @Prop backGroundColor: string;

  build() {
    FunctionalButton({
      params: {
        openType: functionalButtonComponentManager.OpenType.LAUNCH_APP, label: this.name,
        styleOption: {
          styleConfig: new functionalButtonComponentManager.ButtonConfig()
            .type(ButtonType.Normal)
            .width('65vp')
            .height('65vp')
            .fontSize('16')
            .fontColor('rgb(255, 255, 255)')
            .padding(0)
            .borderRadius($r('sys.float.corner_radius_level6'))
            .backgroundColor(this.backGroundColor)
        },
      },
    }).margin({ top: 12, right: 12, bottom: 12 })
  }
}

@Component
struct ButtonInModifier {
  @Prop name: string;
  @Prop backGroundColor: string;

  build() {
    FunctionalButton({
      params: {
        openType: functionalButtonComponentManager.OpenType.LAUNCH_APP,
        label: this.name,
        textModifier: new TextModifier().fontColor(Color.White).fontWeight(FontWeight.Medium),
        buttonModifier: new ButtonModifier()
          .type(ButtonType.Normal)
          .width('65vp')
          .height('65vp')
          .fontSize('16')
          .fontColor('rgb(255, 255, 255)')
          .padding(0)
          .borderRadius($r('sys.float.corner_radius_level6'))
          .backgroundColor(this.backGroundColor),
        loadingProgressModifier: new LoadingProgressModifier().color(Color.White).margin({ left: -4 }),
        styleOption: {
          loading: false,
        },
      },
    }).margin({top: 12, right: 12, bottom: 12})
  }
}

@Entry
@Component
struct Index {
  @State arrow_right: Resource = $r("app.media.arrow_right");
  @State arrow_down: Resource = $r("app.media.arrow_down");
  @State arrow: Resource = this.arrow_right;
  @State flag: boolean = false;
  @State
  private components: ComponentsInfo[] = [
    new ComponentsInfo(0, 'Verify mobile number quickly Button scenario', this.arrow_right),
    new ComponentsInfo(1, 'Open APP Button scenario', this.arrow_right),
    new ComponentsInfo(2, 'Select shipping address Button scenario', this.arrow_right),
    new ComponentsInfo(3, 'Select invoice title Button scenario', this.arrow_right),
    new ComponentsInfo(4, 'Select map location Button scenario', this.arrow_right),
    new ComponentsInfo(5, 'Choose avatar Button scenario', this.arrow_right),
    new ComponentsInfo(6, 'Setting Permissions Button scenario', this.arrow_right),
    new ComponentsInfo(7, 'Province/City/District Selector Input scenario', this.arrow_right),
  ];
  @State
  private component1: ComponentsInfo[] = [
    new ComponentsInfo(0, 'Button Set style', this.arrow_right),
  ];

  build() {
    Column() {
      Navigation() {
        Scroll() {
          Column() {
            TextComponent({ textInfo: 'Diverse scenario-specific components' })
            lists({ components: this.components })
            TextComponent({ textInfo: 'Scenario-specific component style settings' })
            lists({ components: this.component1 })
            FunctionalButton({
              params: {
                openType: functionalButtonComponentManager.OpenType.LAUNCH_APP, label: 'More style settings',
                styleOption: {
                  size: functionalButtonComponentManager.SizeType.DEFAULT,
                  styleConfig: new functionalButtonComponentManager.ButtonConfig()
                    .fontWeight(500)
                    .width('85%')
                    .fontSize('54px')
                    .fontColor('rgb(255, 255, 255)')
                    .margin('32px')
                    .borderRadius('20px')
                    .backgroundColor('rgb(10, 89, 247)')
                },
              },
            })
          }
        }
      }
      .title('Scenario-specific components')
      .titleMode(NavigationTitleMode.Full)
      .backgroundColor('rgb(241, 243, 245)')
    }
    .width('100%')
  }
}