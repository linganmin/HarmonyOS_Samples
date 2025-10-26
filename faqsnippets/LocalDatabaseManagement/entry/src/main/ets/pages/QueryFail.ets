/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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
import { relationalStore } from '@kit.ArkData';

/*
* FAQ:数据库查询失败 14800007
 */
let context: null = null;
let columnUuid: string = 'column_uuid';
class QueryFail{

// [Start QueryFail]
async query( ) {
  const STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'NetMonitor.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };
  let rdbStore: relationalStore.RdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG).then();
  let sql = 'SELECT * FROM net_monitor ORDER BY id desc LIMIT 20';
  let resultSet = await rdbStore.querySql(sql)
  let uuid = this.getString(resultSet, columnUuid)  // report errors
}
/**
 * Retrieve the string column value of the current row in the result set.
 * @param resultSet
 * @param columnName
 * @returns
 */
private getString(resultSet: relationalStore.ResultSet, columnName: string): string | undefined {
  let isColumnNull = resultSet.isColumnNull(resultSet.getColumnIndex(columnName));
  if (isColumnNull){
    return undefined
  } else {
    return resultSet.getString(resultSet.getColumnIndex(columnName))
  }
}
// [End QueryFail]
}