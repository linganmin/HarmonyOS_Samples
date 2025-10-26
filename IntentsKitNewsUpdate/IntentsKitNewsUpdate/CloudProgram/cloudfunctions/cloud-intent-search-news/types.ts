/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

export interface Device {
  deviceId?: string; // Unique device identifier, max 512 chars
  location?: Location; // Geographic location
  timezone?: string; // e.g. "GMT+08:00"
  time?: string; // UTC time in format yyyyMMddHHmmssSSS
  clientIp?: string; // Client IP address, max 32 chars
  deviceType?: number; // 0-12 representing different device types, default 0
}

export interface Location {
  locationSystem: 'BD09LL' | 'GCJ02' | 'WGS84';
  latitude: string; // Format: ddd.dddddd
  longitude: string; // Format: ddd.dddddd
}

export interface PaginationReq {
  limit?: number; // Page size limit
  start?: string; // Starting index, max 16 chars
  maxTotal?: number; // Total count limit
}

export interface QueryBlogInfoReq {
  blogCategory?: string; // Blog category (travel, home, etc.), max 32 chars
  blogAuthor?: string; // Blog author, max 32 chars
  keywords?: string; // Search keywords (comma separated), max 64 chars
}

// Response types
export interface SearchBlogResponse {
  errorCode: string; // Status code, max 32 chars
  errorMessage: string; // Description, max 256 chars
  reply: QueryBlogInfoRsp;
}

export interface QueryBlogInfoRsp {
  items?: BlogInfoItem[]; // Array of blog items, max 200 items
  moreLink?: Interaction; // "View more" link
  pagination?: PaginationRsp;
}

export interface BlogInfoItem {
  entityId: string; // Unique blog ID, max 32 chars
  blogTitle: string; // Blog title, max 32 chars
  blogSubTitle?: string; // Blog subtitle, max 32 chars
  blogType: 'Normal' | 'Video';
  blogCategory: string; // Max 32 chars
  logoURL: ImageInfo; // Thumbnail image
  description: string; // Max 128 chars
  blogAuthor: string; // Max 32 chars
  blogAuthorImage: ImageInfo;
  blogPublishTime: string; // Timestamp format, max 32 chars
  tags?: string[];
  likeCount?: number;
  forwardCount?: number;
  commentCount?: number;
  favorites?: number;
  viewCount?: number;
  detailUrl: Interaction[];
}

export interface PaginationRsp {
  next?: string; // Next page token, max 16 chars
  total: number; // Total count of all items
}

export interface ImageInfo {
  small?: Image;
  large?: Image;
  medium?: Image;
}

export interface Image {
  url: string; // HTTPS URL, max 512 chars
  widthPixels: number; // 1-16384
  heightPixels: number; // 1-16384
}

export interface NativeAppLinkInteraction {
  url: string; // App's deeplink URL, max 512 chars
  appName: string; // App name, max 256 chars
  appPackage: string; // App package name, max 256 chars
  minVersion: number; // Minimum app version code required
  minAndroidAPILevel?: number; // Minimum Android API level required
}

export interface FaLinkInteraction {
  packageName: string; // FA package name (bundleName), max 256 chars
  serviceName: string; // FA service name (abilityName), max 256 chars
  moduleName?: string; // FA module name, max 256 chars
  faParams?: Record<string, any>; // FA parameters as JSON object, max 4000 chars
}

export interface ExecuteIntent {
  bundleName: string; // Package name, max 128 chars
  intentName?: string; // Intent name (e.g. ViewBlog), max 64 chars
  executeMode?: 'foreground'; // Execution mode
  intentParam?: Record<string, any>; // Intent parameters as JSON object, max 4000 chars
}

export interface Interaction {
  webURL?: string; // HTTPS URL, max 512 chars
  deepLink?: NativeAppLinkInteraction;
  faLink?: FaLinkInteraction;
  executeIntent?: ExecuteIntent;
  displayText?: string; // Display text, max 16 chars
}