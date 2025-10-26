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

/**
 *  最佳实践：点击响应优化
 */
import relationalStore from '@ohos.data.relationalStore';
import AccountData from './AccountData';
import Rdb from './Rdb';

export default class AccountTable {
  private accountTable = new Rdb('accountTable',
    'CREATE TABLE IF NOT EXISTS accountTable(id INTEGER PRIMARY KEY AUTOINCREMENT, accountType INTEGER, ' +
      'typeText TEXT, amount INTEGER)',
    ['id', 'accountType', 'typeText', 'amount']);

  query(amount: number, callback: Function, isAll: boolean = true) {
    let predicates = new relationalStore.RdbPredicates('accountTable');
    if (!isAll) {
      predicates.equalTo('amount', amount);
    }
    this.accountTable.query(predicates, (resultSet: relationalStore.ResultSet) => {
      let count: number = resultSet.rowCount;
      if (count === 0 || typeof count === 'string') {
        callback([]);
      } else {
        resultSet.goToFirstRow();
        const result: AccountData[] = [];
        // [Start edit_before]
        for (let i = 0; i < count; i++) {
          let tmp: AccountData = {
            id: 0,
            accountType: 0,
            typeText: '',
            amount: 0
          };
          tmp.id = resultSet.getDouble(resultSet.getColumnIndex('id'));
          tmp.accountType = resultSet.getDouble(resultSet.getColumnIndex('accountType'));
          tmp.typeText = resultSet.getString(resultSet.getColumnIndex('typeText'));
          tmp.amount = resultSet.getDouble(resultSet.getColumnIndex('amount'));
          result[i] = tmp;
          resultSet.goToNextRow();
        }
        // [End edit_before]
        // [Start edit_after]
        const idIndex = resultSet.getColumnIndex("id");
        const accountTypeIndex = resultSet.getColumnIndex("accountType");
        const typeTextIndex = resultSet.getColumnIndex("typeText");
        const amountIndex = resultSet.getColumnIndex("amount");
        for (let i = 0; i < count; i++) {
          let tmp: AccountData = {
            id: 0,
            accountType: 0,
            typeText: '',
            amount: 0
          };
          tmp.id = resultSet.getDouble(idIndex);
          tmp.accountType = resultSet.getDouble(accountTypeIndex);
          tmp.typeText = resultSet.getString(typeTextIndex);
          tmp.amount = resultSet.getDouble(amountIndex);
          result[i] = tmp;
          resultSet.goToNextRow();
        }
        // [End edit_after]
        callback(result);
      }
    });
  }
}
