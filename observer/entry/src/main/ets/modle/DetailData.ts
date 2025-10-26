/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import { radio,call,data,observer } from '@kit.TelephonyKit';

export default class DetailData {
  // Network registration status
  public networkState: radio.NetworkState;
  // Network signal strength information
  public signalInformation: Array<radio.SignalInformation>;
  public callState?: call.CallState;
  public callNumber?: string;
  // Cellular data link connection status
  public dataConnectState?: data.DataConnectState;
  // Wireless access technology
  public ratType?: radio.RadioTechnology;
  // Cellular data stream type
  public dataFlowType: data.DataFlowType;
  // SIM card type and status
  public simStateData: observer.SimStateData;

  constructor() {
    this.networkState = undefined;
    this.signalInformation = undefined;
    this.callState = undefined;
    this.callNumber = undefined;
    this.dataConnectState = undefined;
    this.ratType = undefined;
    this.dataFlowType = undefined;
    this.simStateData = undefined;
  }
}
