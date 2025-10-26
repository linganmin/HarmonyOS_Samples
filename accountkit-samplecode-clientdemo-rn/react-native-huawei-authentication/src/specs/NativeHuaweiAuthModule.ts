/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
// This is a declaration file that uses TurboModule to call the Native API for obtaining an anonymous mobile number.
import { TurboModuleRegistry, RootTag } from "react-native"; // This contains the function for loading Turbo Native Module.
import type { TurboModule } from "react-native/Libraries/TurboModule/RCTExport"; // Define the basic APIs of Turbo Native Module.

// Response body of obtaining an anonymous mobile number.
export type HuaweiAuthRequestResponse = {
  data: DataRsp;
  errorCode: string;
  errorMessage: string
};

// extraInfo
export type ExtraInfoRsp = {
  localNumberConsistency: boolean;
  quickLoginAnonymousPhone: string
};

// Data
export type DataRsp = {
  authorizedScopes: Array<string>;
  extraInfo: ExtraInfoRsp;
};

// Declare the JavaScript API for obtaining an anonymous mobile number. Spec must be used in the API name.
export interface Spec extends TurboModule {
  getQuickLoginAnonymousPhone(): Promise<HuaweiAuthRequestResponse>;
}

// Call TurboModuleRegistry.get and pass the module name. The module will be loaded when Turbo Native Module is available.
export default TurboModuleRegistry.get<Spec>("HuaweiAuthTurboModule")!;
