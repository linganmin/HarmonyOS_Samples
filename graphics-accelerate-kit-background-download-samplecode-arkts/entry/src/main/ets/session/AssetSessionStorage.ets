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

import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { TAG, DOMAINID } from '../common/CommonConstants';
import { assetDownloadManager } from '@kit.GraphicsAccelerateKit';
import AssetManifest from '../common/AssetAccelManifest';

export interface ResourceInfo {
  id: number;
  name: string;
  url: string;
  size: number;
  groupId: string;
  status: assetDownloadManager.State;
  isSubmit: boolean;
}

export interface GroupInfo {
  totalSize: number;
  groupId: string;
  downloadedSize: number;
  createTime: number;
}
const SQL_CREATE_RESOURCES_TABLE: string =
  'CREATE TABLE IF NOT EXISTS [resources_info](' +
    '[url] TEXT PRIMARY KEY,' +
    '[groupId] TEXT,' +
    '[name] TEXT,' +
    '[id] INTEGER NOT NULL DEFAULT 0,' +
    '[size] INTEGER NOT NULL DEFAULT 0,' +
    '[status] INTEGER NOT NULL DEFAULT 0,' +
    '[isSubmit] INTEGER NOT NULL DEFAULT 0)';

const SQL_CREATE_GROUP_TABLE: string =
  'CREATE TABLE IF NOT EXISTS [group_info](' +
    '[groupId] TEXT PRIMARY KEY,' +
    '[totalSize] INTEGER NOT NULL DEFAULT 0,' +
    '[downloadedSize] INTEGER NOT NULL DEFAULT 0,' +
    '[createTime] INTEGER NOT NULL DEFAULT 0)';

export class AssetSessionStorage {
  private rdbStore_: relationalStore.RdbStore;

  private constructor(rdbStore: relationalStore.RdbStore) {
    this.rdbStore_ = rdbStore;
  }

  private async queryGroupInfo(predicates: relationalStore.RdbPredicates): Promise<GroupInfo> {
    hilog.info(DOMAINID, TAG, 'queryGroupInfo start.');
    let resultSet: relationalStore.ResultSet = await this.rdbStore_.query(predicates, []);
    if (resultSet.rowCount === 0) {
      resultSet.close();
      throw new Error('group_info is empty');
    }
    while (resultSet.goToNextRow()) {
      let group: GroupInfo = {
        totalSize: resultSet.getLong(resultSet.getColumnIndex('totalSize')),
        groupId: resultSet.getString(resultSet.getColumnIndex('groupId')),
        downloadedSize: resultSet.getLong(resultSet.getColumnIndex('downloadedSize')),
        createTime: resultSet.getLong(resultSet.getColumnIndex('createTime'))
      }
      resultSet.close();
      return group;
    }
    throw new Error('group_info is empty');
  }

  static async create(context: common.Context): Promise<AssetSessionStorage> {
    let loadRdbStoreFunc = (context: common.Context): Promise<relationalStore.RdbStore> => {
      return new Promise((resolve, reject) => {
        const STORE_CONFIG: relationalStore.StoreConfig = {
          name: 'RdbTest.db',
          securityLevel: relationalStore.SecurityLevel.S1
        };
        relationalStore.getRdbStore(context, STORE_CONFIG).then(async (rdbStore: relationalStore.RdbStore) => {
          if (rdbStore != undefined) {
            try {
              rdbStore.executeSync(SQL_CREATE_RESOURCES_TABLE);
              rdbStore.executeSync(SQL_CREATE_GROUP_TABLE);
            } catch (error) {
              hilog.error(DOMAINID, TAG, `delete failed, code is ${error.code}, message is ${error.message}`);
              reject();
            }
          }
          resolve(rdbStore);
        }).catch((error: BusinessError) => {
          hilog.error(DOMAINID, TAG, `Get RdbStore failed, code is ${error.code},message is ${error.message}`);
          reject();
        })
      })
    }
    let rdbStore: relationalStore.RdbStore = await loadRdbStoreFunc(context);
    return new AssetSessionStorage(rdbStore);
  }

  async containGroupData(groupId: string): Promise<boolean> {
    return new Promise((resolve) => {
      this.queryGroupInfoByGroupId(groupId).then(() => {
        resolve(true);
      }).catch(() => {
        resolve(false);
      })
    });
  }

  insertDownloadResourceInfoByGroupID(resources: Array<AssetManifest.AssetAccelResource>, version: string) {
    hilog.info(DOMAINID, TAG, `insertDownloadResourceInfoByGroupID, insertNum is ${resources}`);
    let totalSize = 0;
    let resourcesValueBuckets: Array<relationalStore.ValuesBucket> = resources.map((ele) => {
      totalSize += ele.fileLength;
      const valueBucket: relationalStore.ValuesBucket = {
        'url': ele.downloadUrl,
        'groupId': version,
        'name': ele.fileName,
        'id': ele.fileId + '',
        'size': ele.fileLength,
        'status': assetDownloadManager.State.CREATED,
        'isSubmit': 0
      };
      return valueBucket;
    })
    try {
      let insertNum: number = this.rdbStore_.batchInsertSync('resources_info', resourcesValueBuckets);
      hilog.info(DOMAINID, TAG, `batchInsert is success, insertNum is ${insertNum}`);
    } catch (error) {
      hilog.error(DOMAINID, TAG, `batchInsert is failed, code is ${error.code},message is ${error.message}`);
    }
    const groupValueBucket: relationalStore.ValuesBucket = {
      'groupId': version,
      'totalSize': totalSize,
      'downloadedSize': 0,
      'createTime': new Date().getTime()
    };
    try {
      this.rdbStore_.insertSync('group_info', groupValueBucket);
    } catch (error) {
      hilog.error(DOMAINID, TAG, `Insert is failed, code is ${error.code},message is ${error.message}`);
    }
  }

  async queryUnSubmitResources(groupId: string, limitAS: number): Promise<assetDownloadManager.AssetDownloadConfig[]> {
    let assetDownloadResult: Array<assetDownloadManager.AssetDownloadConfig> = [];
    let predicates = new relationalStore.RdbPredicates('resources_info');
    predicates.equalTo('groupId', groupId)
      .and()
      .equalTo('isSubmit', 0)
      .limitAs(limitAS);
    let resultSet: relationalStore.ResultSet = await this.rdbStore_.query(predicates, []);
    hilog.info(DOMAINID,
      TAG, `ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);
    while (resultSet.goToNextRow()) {
      let assetDownload: assetDownloadManager.AssetDownloadConfig = {
        fileName: resultSet.getString(resultSet.getColumnIndex('name')),
        url: resultSet.getString(resultSet.getColumnIndex('url')),
        isEssential: false,
        identifier: resultSet.getLong(resultSet.getColumnIndex('id')) + '',
        groupId: resultSet.getString(resultSet.getColumnIndex('groupId'))
      }
      assetDownloadResult.push(assetDownload);
    }
    hilog.info(DOMAINID, TAG, `queryUnSubmitResources length is ${assetDownloadResult.length}`);
    return assetDownloadResult;
  }

  async queryGroupInfoForLatest(): Promise<GroupInfo> {
    let predicates = new relationalStore.RdbPredicates('group_info');
    predicates.orderByDesc('groupId').limitAs(1);
    try {
      let group: GroupInfo = await this.queryGroupInfo(predicates);
      return group;
    } catch (error) {
      return Promise.resolve({} as GroupInfo);
    }
  }

  async containLocalVersion(): Promise<boolean> {
    try {
      await this.queryGroupInfoForLatest();
    } catch (error) {
      return false;
    }
    return true;
  }

  queryGroupInfoByGroupId(groupId: string): Promise<GroupInfo> {
    let predicates = new relationalStore.RdbPredicates('group_info');
    predicates.equalTo('groupId', groupId);
    return this.queryGroupInfo(predicates);
  }

  async queryResourceInfoByGroupId(groupId: string): Promise<ResourceInfo[]> {
    let queryResourcesPredicates = new relationalStore.RdbPredicates('resources_info');
    queryResourcesPredicates.equalTo('groupId', groupId);
    let resultSet: relationalStore.ResultSet = await this.rdbStore_.query(queryResourcesPredicates, []);
    if (resultSet.rowCount === 0) {
      resultSet.close();
      throw new Error(`resources_info table not exist assetInfo by ${groupId}`);
    }
    let resourceList: Array<ResourceInfo> = [];
    while (resultSet.goToNextRow()) {
      let resource: ResourceInfo = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        url: resultSet.getString(resultSet.getColumnIndex('url')),
        size: resultSet.getLong(resultSet.getColumnIndex('size')),
        groupId: resultSet.getString(resultSet.getColumnIndex('groupId')),
        status: resultSet.getLong(resultSet.getColumnIndex('status')),
        isSubmit: resultSet.getLong(resultSet.getColumnIndex('isSubmit')) > 0? true : false,
      }
      resourceList.push(resource);
    }
    if (resourceList.length > 0) {
      return resourceList;
    }
    throw new Error(`resources_info table not exist assetInfo by ${groupId}`);
  }

  async queryResourceInfo(url: string): Promise<ResourceInfo> {
    let queryResourcesPredicates = new relationalStore.RdbPredicates('resources_info');
    queryResourcesPredicates.equalTo('url', url);
    let resultSet: relationalStore.ResultSet = await this.rdbStore_.query(queryResourcesPredicates, []);
    if (resultSet.rowCount === 0) {
      resultSet.close();
      throw new Error(`resources_info table not exist assetInfo by ${url}`);
    }
    while (resultSet.goToNextRow()) {
      let resource: ResourceInfo = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        url: resultSet.getString(resultSet.getColumnIndex('url')),
        size: resultSet.getLong(resultSet.getColumnIndex('size')),
        groupId: resultSet.getString(resultSet.getColumnIndex('groupId')),
        status: resultSet.getLong(resultSet.getColumnIndex('status')),
        isSubmit: resultSet.getLong(resultSet.getColumnIndex('isSubmit')) > 0? true : false
      }
      return resource;
    }
    throw new Error(`resources_info table not exist assetInfo by ${url}`);
  }

  /**
   * Update the download resource status.
   */
  async updateAssetDataByStatus(url: string, status: number) {
    const updateResourcesValueBucket: relationalStore.ValuesBucket = {
      'status': status
    };
    let updateResourcesPredicates = new relationalStore.RdbPredicates('resources_info');
    updateResourcesPredicates.equalTo('url', url);
    await this.rdbStore_.update(updateResourcesValueBucket, updateResourcesPredicates);
    let resource: ResourceInfo = await this.queryResourceInfo(url);
    let group: GroupInfo = await this.queryGroupInfoByGroupId(resource.groupId);
    const valueBucket: relationalStore.ValuesBucket = {
      'downloadedSize': group.downloadedSize + resource.size
    };
    let updateGroupPredicates = new relationalStore.RdbPredicates('group_info');
    updateGroupPredicates.equalTo('groupId', resource.groupId);
    await this.rdbStore_.update(valueBucket, updateGroupPredicates);
  }

  /*
   * Update Submit Status.
   */
  async updateSubmitStatus(asset : assetDownloadManager.AssetDownloadConfig[]) {
    for (let index = 0; index < asset.length; index++) {
      let url : string = asset[index].url;
      let updateResourcesPredicates = new relationalStore.RdbPredicates('resources_info');
      updateResourcesPredicates.equalTo('url', url);
      const updateResourcesValueBucket: relationalStore.ValuesBucket = {
        'isSubmit': 1
      }
      await this.rdbStore_.update(updateResourcesValueBucket, updateResourcesPredicates);
    }
  }

  async updateSuccessData(url: string) {
    await this.updateAssetDataByStatus(url, assetDownloadManager.State.FINISHED);
  }

  async updateFailedData(url: string) {
    await this.updateAssetDataByStatus(url, assetDownloadManager.State.FAILED);
  }
}
