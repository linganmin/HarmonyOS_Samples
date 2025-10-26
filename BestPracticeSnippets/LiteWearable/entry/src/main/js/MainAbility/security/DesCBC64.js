// [Start is_key_item_exist]
// [Start delete_key_process]
import huks from '@ohos.security.huks';

const KEY_ALIAS = 'DesCBC64KeyAlias';
// [StartExclude delete_key_process]
function isKeyItemExist() {
    let huksInfo;
    let emptyOptions = {
        properties: []
    };

    huks.isKeyItemExist(KEY_ALIAS, emptyOptions, (err, data) => {
        if (data) {
            huksInfo = 'The key:' + KEY_ALIAS + ' exists';
        } else {
            huksInfo = 'The key doesn\'t exist errcode:' + err.code + ' ： ' + err.message;
        }
    });

    return huksInfo;
}
// [End is_key_item_exist]
// [EndExclude delete_key_process]
function deleteKeyProcess() {
    let huksInfo;
    let emptyOptions = {
        properties: []
    };
    huks.deleteKeyItem(KEY_ALIAS, emptyOptions, (err, data) => {
        if (err) {
            huksInfo = 'deleteKeyItem error return code:' + err.code + ' ： ' + err.message;
        } else {
            huksInfo = 'The key has been deleted';
        }
    })
    return huksInfo;
}
// [End delete_key_process]