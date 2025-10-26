/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { distributedKVStore } from '@kit.ArkData';
import KVStore from '../common/utils/KVStore';
import { KVStoreType } from '../viewmodel/KVStoreType';
import { ReadWrite } from './ReadWritePage';

@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @State text: string = 'S1';
  @State index: number = 0;
  @State securityLevel: distributedKVStore.SecurityLevel = distributedKVStore.SecurityLevel.S1;
  @StorageLink('encrypted') encrypted: boolean = false;
  @StorageLink('kvStore') kvStore: KVStore | undefined = undefined;
  @StorageLink('kvStoreAll') kvStoreAll: KVStoreType[] = [];

  UIContext = this.getUIContext();

  @Builder
  pageMap(name: string) {
    if(name === 'readWritePage'){
      ReadWrite()
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Column() {
          Row() {
            Text($r('app.string.select'))
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.mask_secondary'))
              .lineHeight(20)
              .margin({
                top: 28,
                bottom: 12
              })
            Row() {
              Checkbox({ name: 'encrypt', group: 'checkboxGroup' })
                .select(false)
                .height(20)
                .width(20)
                .selectedColor('#0A59F7')
                .shape(CheckBoxShape.CIRCLE)
                .onChange((value: boolean) => {
                  this.encrypted = value;
                })
              Text($r('app.string.encrypt'))
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.mask_secondary'))
                .lineHeight(20)
                .margin({ left: 8 })
            }
            .height('100%')
            .margin({
              top: 28,
              bottom: 12
            })
          }
          .height(60)
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({
            top: 8,
            bottom: 12
          })

          Select([{ value: 'S1' },
            { value: 'S2' },
            { value: 'S3' },
            { value: 'S4' }])
            .selected(this.index)
            .value(this.text)
            .font({
              size: 16,
              weight: 500
            })
            .fontColor($r('sys.color.font_primary'))
            .selectedOptionFont({
              size: 16,
              weight: 500
            })
            .optionFont({
              size: 16,
              weight: 500
            })
            .space(8)
            .width('100%')
            .arrowPosition(ArrowPosition.END)
            .menuAlign(MenuAlignType.START, { dx: 0, dy: 0 })
            .optionWidth(200)
            .optionHeight(300)
            .onSelect((index: number, text?: string) => {
              this.index = index;
              if (text) {
                this.text = text;
                if (text === 'S1') {
                  this.securityLevel = distributedKVStore.SecurityLevel.S1;
                } else if (text === 'S2') {
                  this.securityLevel = distributedKVStore.SecurityLevel.S2;
                } else if (text === 'S3') {
                  this.securityLevel = distributedKVStore.SecurityLevel.S3;
                } else if (text === 'S4') {
                  this.securityLevel = distributedKVStore.SecurityLevel.S4;
                }
              }
            })
        }

        Button($r('app.string.create'))
          .width('100%')
          .height('40vp')
          .fontSize('16fp')
          .backgroundColor('#0A59F7')
          .fontWeight(FontWeight.Medium)
          .onClick(async () => {
            this.kvStoreAll = [];
            this.kvStore = undefined;
            this.kvStore = new KVStore(this.encrypted, this.securityLevel, this.UIContext);
            setTimeout(() => {
              this.pageInfos.clear();
              this.pageInfos.pushPath(new NavPathInfo('readWritePage', []));
            }, 200)
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .height('100%')
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        bottom: 16
      })
    }
    .title($r('app.string.title'))
    .width('100%')
    .height('100%')
    .hideToolBar(true)
    .navDestination(this.pageMap)
    .backgroundColor('#F1F3F5')
  }
}