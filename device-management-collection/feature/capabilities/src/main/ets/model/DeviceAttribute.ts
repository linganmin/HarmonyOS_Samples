/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

export class DeviceAttribute {
  public busAddress: number;
  public deviceAddress: number;
  public serial: string; // serial number
  public name: string; // Equipment name
  public manufacturerName: string;
  public productName: string;
  public version: string;
  public vendorId: number;
  public productId: number;
  public clazz: number; // Equipment category

  constructor() {
    this.busAddress = 0;
    this.deviceAddress = 0;
    this.serial = '';
    this.name = '';
    this.manufacturerName = '';
    this.productName = '';
    this.version = '';
    this.vendorId = 0;
    this.productId = 0;
    this.clazz = 0;
  }
}