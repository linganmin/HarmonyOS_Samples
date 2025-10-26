// [Start hmac_generate]
// [Start hmac_process]
import huks from '@ohos.security.huks';

// HMACKeyAlias - Alias used to distinguish the generated KEY.
const HMAC_KEY_ALIAS = 'HMACKeyAlias';
// [StartExclude hmac_generate]
// Plain text, data before encryption.
let plainText = 'HMACSAdffssghABC5612345612345192';
// Ciphertext, storing the encrypted data.
let cipherText = '';
// Operation handle.
let handle;
// [EndExclude hmac_generate]
// [StartExclude hmac_process]
function getHMACGenProperties() {
    let properties = new Array();
    let index = 0;
    // algorithm
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
        value: huks.HuksKeyAlg.HUKS_ALG_AES
    };
    // key length.
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
        value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256
    };
    // Key usage.
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_MAC
    };
    return properties;
}

function generateHMACKey() {
    let huksInfo;
    let options = {
        properties: getHMACGenProperties()
    }
    huks.generateKeyItem(HMAC_KEY_ALIAS, options, (err, data) => {
        if (err) {
            huksInfo = 'generateKeyHMAC return code:' + err.code + ' ： ' + err.message;
        } else {
            huksInfo = 'The key has been generated' + JSON.stringify(data);
        }
    });
    return huksInfo;
}
// [End hmac_generate]
// [EndExclude hmac_process]
function uint8ArrayToString(fileData) {
    let dataString = '';
    for (let i = 0; i < fileData.length; i++) {
        dataString += String.fromCharCode(fileData[i]);
    }
    return dataString;
}

function stringToUnit8Array(str) {
    let arr = [];
    for (let i = 0, j = str.length; i < j; ++i) {
        arr.push(str.charCodeAt(i));
    }
    return new Uint8Array(arr);
}

function getHMACProperties() {
    let properties = new Array();
    let index = 0;
    // algorithm.
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
        value: huks.HuksKeyAlg.HUKS_ALG_HMAC
    };
    // key length.
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
        value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256
    };
    // Key usage.
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_MAC
    };
    // digest algorithm.
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_DIGEST,
        value: huks.HuksKeyPurpose.HUKS_DIGEST_SHA256
    };
    return properties;
}

function HMACProcess() {
    let huksInfo;
    let ret = true;
    let initOptions = {
        properties: getHMACProperties(),
        inData: new Uint8Array()
    }
    let updateOptions = {
        properties: getHMACProperties(),
        inData: stringToUnit8Array(plainText.substring(0, 16))
    }
    let finishOptions = {
        properties: getHMACProperties(),
        inData: stringToUnit8Array(plainText.substring(16, 32))
    }

    huks.initSession(HMAC_KEY_ALIAS, initOptions, (initErr, initData) => {
        if (initErr) {
            huksInfo = 'HMAC initSession return code:' + initErr.code + ' ： ' + initErr.message;
            ret = false;
            huks.abortSession(initData.handle, initOptions, (abortErr, abortData) => {
                if (abortErr) {
                    huksInfo = 'HMAC init abortSession return code:' + abortErr.code + ' ： ' + abortErr.message;
                }
            });
        } else {
            handle = initData.handle;
        }
    });
    if (!ret) {
        return huksInfo;
    }

    huks.updateSession(handle, updateOptions, (updateErr, updateData) => {
        if (updateErr) {
            huksInfo = 'HMAC updateSession return code:' + updateErr.code + ' ： ' + updateErr.message;
            ret = false;
            huks.abortSession(handle, updateOptions, (abortErr, abortData) => {
                if (abortErr) {
                    huksInfo = 'HMAC update abortSession return code:' + abortErr.code + ' ： ' + abortErr.message;
                }
            });
        }
    });

    if (!ret) {
        return huksInfo;
    }

    huks.finishSession(handle, finishOptions, (finishErr, finishData) => {
        if (finishErr) {
            ret = false;
            huksInfo = 'encrypt HMAC finishSession return code:' + finishErr.code + ' ： ' + finishErr.message;
            huks.abortSession(handle, finishOptions, (abortErr, abortData) => {
                if (abortErr) {
                    huksInfo =
                        'encrypt HMAC finish abortSession return code:' + abortErr.code + ' ： ' + abortErr.message;
                }
            });
        } else {
            // HMAC ciphertext reception.
            cipherText = uint8ArrayToString(finishData.outData);
        }
    });
    if (!ret) {
        return huksInfo;
    } else {
        huksInfo = 'success:' + cipherText;
    }
    return huksInfo;
}
// [End hmac_process]