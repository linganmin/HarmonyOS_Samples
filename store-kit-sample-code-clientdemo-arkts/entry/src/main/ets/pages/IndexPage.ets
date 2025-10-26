/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */
import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { EntryItemInfo } from '../common/bean/EntryItemInfo';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct IndexPage {
  @State items: EntryItemInfo[] = [
    new EntryItemInfo('load_product', $r("app.string.load_product"), 'pages/LoadProduct'),
    new EntryItemInfo('load_service', $r("app.string.load_service"), 'pages/LoadService'),
    new EntryItemInfo('getAdsVerificationVersion', $r("app.string.getAdsVerificationVersion"),
      'pages/GetAdsVerificationVersion'),
    new EntryItemInfo('getSelfSceneCode', $r("app.string.getSelfSceneCode"), 'pages/GetSelfSceneCode'),
    new EntryItemInfo('load_install', $r("app.string.load_install"), 'pages/LoadInstallService'),
    new EntryItemInfo('attribution', $r('app.string.attribution_manager'), ''),
    new EntryItemInfo('check_update', $r("app.string.check_update"), 'pages/CheckUpdatePage'),
    new EntryItemInfo('getAppPrivacyMgmtInfo', $r("app.string.getAppPrivacyMgmtInfo"),
      'pages/GetAppPrivacyMgmtInfo'),
    new EntryItemInfo('getAppPrivacyResult', $r("app.string.getAppPrivacyResult"),
      'pages/GetAppPrivacyResult'),
    new EntryItemInfo('disableService', $r("app.string.disableService"),
      'pages/DisableService')
  ];

  build() {
    Column() {
      List({ space: 20 }) {
        ForEach(this.items, (item: EntryItemInfo) => {
          ListItem() {
            Button(item.itemName)
              .id(item.itemId)
              .width('100%')
              .onClick(() => {
                if (item.itemId == 'attribution') {
                  this.jumpToAttribution();
                } else {
                  console.info(`Succeeded in clicking the 'Next' button.`)
                  router.pushUrl({ url: item.itemClickAction as string }).then(() => {
                    console.info('Succeeded in jumping to the second page.')
                  }).catch((err: BusinessError) => {
                    console.error(`Failed to jump to the second page.Code is ${err.code}, message is ${err.message}`)
                  })
                }
              })
          }
        }, (item: EntryItemInfo) => item.itemId)
      }
      .alignListItem(ListItemAlign.Center)
      .width('100%')
      .height('100%')
    }
    .margin(16)
    .height('100%')
  }

  jumpToAttribution(): void {
    let context = getContext(this) as common.UIAbilityContext;
    context.startAbility({
      bundleName: 'com.example.store.kit.demo',
      moduleName: 'Attribution',
      abilityName: 'AttributionAbility'
    }).then(() => {
      console.info('Succeeded in jumping to the AttributionAbility.');
    }).catch((err: BusinessError) => {
      console.error(`Failed to jump to the AttributionAbility.Code is ${err.code}, message is ${err.message}`);
    });
  }
}