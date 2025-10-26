// [Start import_key]
// [Start export_key]
import huks from '@ohos.security.huks';

// [StartExclude export_key]
// Key material.
let plainTextKey = new Uint8Array([
    0x1d, 0x2c, 0x3a, 0x4b, 0x5e, 0x6f, 0x7d, 0x8a, 0x9c, 0xab, 0xbc, 0xcd, 0xde, 0xef, 0xf1, 0x23
]);
// [EndExclude export_key]
// Confirm the key alias.
const KEY_ALIAS = 'keyAlias';

// [StartExclude export_key]
// Package the set of key attributes and key materials.
function getImportKeyProperties() {
    let properties = new Array();
    let index = 0;
    // algorithm.
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
        value: huks.HuksKeyAlg.HUKS_ALG_AES
    };
    // Key length (128/192/256).
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
        value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_128
    };
    // Key usage: When generating the key,
    // using it can limit the usage rights of the key (AES is generally used for encryption and decryption).
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT | huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT
    };
    return properties
}

// Explicitly imported key.
function importKey() {
    let huksInfo;
    let ret = true;
    let options = {
        properties: getImportKeyProperties(),
        inData: plainTextKey
    }
    huks.importKeyItem(KEY_ALIAS, options, (initErr, initData) => {
        if (initErr) {
            ret = false;
            huksInfo = 'import key:' + initErr.code + ' ： ' + initErr.message;
            huks.abortSession(initData.handle, options, (abortErr, abortData) => {
                if (abortErr) {
                    huksInfo = 'import key init abortSession return code:' + abortErr.code + ' ： ' + abortErr.message;
                }
            });
        } else {
            huksInfo = uint8ArrayToString(initData.outData);
        }
    });

    if (!ret) {
        return huksInfo + ' import failed';
    }

    return huksInfo + ' import succeed';
}

function uint8ArrayToString(fileData) {
    let dataString = '';
    for (let i = 0; i < fileData.length; i++) {
        dataString += String.fromCharCode(fileData[i]);
    }

    return dataString;
}
// [End import_key]
// [EndExclude export_key]
function exportKeyProcess() {
    let huksInfo;
    let emptyOptions = {
        properties: []
    }

    huks.exportKeyItem(KEY_ALIAS, emptyOptions, (err, data) => {
        if (err) {
            huksInfo = 'exportKeyItem error return code:' + err.code + ' ： ' + err.message;
        } else {
            huksInfo = uint8ArrayToString(data.outData);
        }
    })

    return huksInfo;
}
// [End export_key]