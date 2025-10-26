/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export interface DataInfo {
  data: ArrayBuffer,
  size: number,
  code: number,
}

export interface EventInfo {
  code: number;
}

interface ServiceCollaboration_CollaborationDeviceInfo {
  deviceType: number;
  deviceNetworkId: string;
  deviceName: string;
  filterNum: number;
  serviceCollaborationFilterType: ServiceCollaborationFilterType[];
}

export enum ServiceCollaborationFilterType {
  TAKE_PHOTO = 'TAKE_PHOTO',
  SCAN_DOCUMENT = 'SCAN_DOCUMENT',
  IMAGE_PICKER = 'IMAGE_PICKER'
}

export const Demo_HMS_ServiceCollaboration_GetCollaborationDeviceInfos: () => ServiceCollaboration_CollaborationDeviceInfo[];

export const Demo_HMS_ServiceCollaboration_StartCollaboration: (serviceCollaborationFilterType: number,
  networkID: string, onDataReceived: (result: DataInfo) => void, onEventReceived: (event: EventInfo) => void) => number;

export const Demo_HMS_ServiceCollaboration_StopCollaboration: (collaborationId: number) => number;