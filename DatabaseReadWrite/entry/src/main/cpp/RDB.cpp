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
#include "RDB.h"

void RDB::Rdb_init(std::string databaseDir, std::string bundleName) {
    config.dataBaseDir = databaseDir.c_str();
    config.storeName = "RdbTest.db";
    config.bundleName = bundleName.c_str();
    config.moduleName = "entry";
    config.securityLevel = OH_Rdb_SecurityLevel::S1;
    config.isEncrypt = false;
    config.selfSize = sizeof(OH_Rdb_Config);
    config.area = RDB_SECURITY_AREA_EL1;

    int errCode = 0;
    store_ = OH_Rdb_GetOrOpen(&config, &errCode);
}


void RDB::Rdb_add(std::string name, int64_t price) {
    char createTableSql[] =
        "CREATE TABLE IF NOT EXISTS GOODS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT NOT NULL, PRICE INTEGER)";
    OH_Rdb_Execute(store_, createTableSql);

    OH_VBucket *valueBucket = OH_Rdb_CreateValuesBucket();
    valueBucket->putText(valueBucket, "NAME", name.c_str());
    valueBucket->putInt64(valueBucket, "PRICE", price);

    int rowId = OH_Rdb_Insert(store_, "GOODS", valueBucket);

    valueBucket->destroy(valueBucket);
}
void RDB::Rdb_change(int64_t id, std::string changedName, int64_t changedPrice) {
    OH_VBucket *valueBucket = OH_Rdb_CreateValuesBucket();
    valueBucket->putText(valueBucket, "NAME", changedName.c_str());
    valueBucket->putInt64(valueBucket, "PRICE", changedPrice);

    OH_Predicates *predicates = OH_Rdb_CreatePredicates("GOODS");
    OH_VObject *valueObject = OH_Rdb_CreateValueObject();

    valueObject->putInt64(valueObject, &id, 1);
    predicates->equalTo(predicates, "ID", valueObject);

    int changeRows = OH_Rdb_Update(store_, valueBucket, predicates);
    valueObject->destroy(valueObject);
    valueBucket->destroy(valueBucket);
    predicates->destroy(predicates);
}
std::vector<Good> RDB::Rdb_search(void) {
    std::vector<Good> searchResult;

    OH_Predicates *predicates = OH_Rdb_CreatePredicates("GOODS");
    const char *columnNames[] = {"ID", "NAME", "PRICE"};
    int len = sizeof(columnNames) / sizeof(columnNames[0]);
    OH_Cursor *cursor = OH_Rdb_Query(store_, predicates, columnNames, len);

    int columnCount = 0;
    cursor->getColumnCount(cursor, &columnCount);

    int64_t id;
    char name[30] = "";
    int64_t price;
    while (cursor->goToNextRow(cursor) == OH_Rdb_ErrCode::RDB_OK) {
        cursor->getInt64(cursor, 0, &id);
        cursor->getText(cursor, 1, name, 30);
        cursor->getInt64(cursor, 2, &price);
        searchResult.push_back({id, name, price});
    }

    predicates->destroy(predicates);
    cursor->destroy(cursor);
    return searchResult;
}
void RDB::Rdb_delete(int64_t id) {
    OH_Predicates *predicates = OH_Rdb_CreatePredicates("GOODS");
    OH_VObject *valueObject = OH_Rdb_CreateValueObject();

    valueObject->putInt64(valueObject, &id, 1);
    predicates->equalTo(predicates, "ID", valueObject);

    int deleteRows = OH_Rdb_Delete(store_, predicates);

    valueObject->destroy(valueObject);
    predicates->destroy(predicates);
}

void RDB::Rdb_deleteRdb(void) {
    OH_Rdb_CloseStore(store_);
    OH_Rdb_DeleteStore(&config);
}