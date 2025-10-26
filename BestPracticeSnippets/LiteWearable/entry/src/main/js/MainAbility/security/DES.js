// [Start des_generate]
import huks from '@ohos.security.huks';

// [Start des_encrypt]
// [Start des_decrypt]
// Alias, used to distinguish the generated KEY.
const DES_CBC_64_KEY_ALIAS = 'DesCBC64KeyAlias';
// [StartExclude des_generate]
// Three-part handle, used for connecting three-part context.
let handle;
let IV = '12345678';
// Plain text, data before encryption.
let plainText = 'DESAAAdffssghCBC5612345612345L64';
// Ciphertext, storing the encrypted data.
let cipherText = '';
// [EndExclude des_generate]

// [StartExclude des_encrypt]
// [StartExclude des_decrypt]
// Configure the Tag required for generating the key.
function getDesGenProperties() {
    let properties = new Array();
    let index = 0;
    // DES algorithm.
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
        value: huks.HuksKeyAlg.HUKS_ALG_DES
    };
    // Key length: 64.
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
        value: huks.HuksKeySize.HUKS_DES_KEY_SIZE_64
    };
    // Key usage, encryption and decryption.
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT | huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT
    };

    return properties;
}

// Generate a key.
function generateDESKey() {
    let huksInfo;
    let options = { properties: getDesGenProperties() }
    huks.generateKeyItem(DES_CBC_64_KEY_ALIAS, options, (err, data) => {
        if (err) {
            huksInfo = 'generateKeyDES return code:' + err.code + ' ： ' + err.message;
        } else {
            huksInfo = 'The key has been generated:' + JSON.stringify(data);
        }
    });
    return huksInfo;
}
// [EndExclude des_encrypt]
// [End des_generate]
function getDesCBCEncryptProperties() {
    let properties = new Array();
    let index = 0;
    // algorithm.
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
        value: huks.HuksKeyAlg.HUKS_ALG_DES
    };

    // key length.
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
        value: huks.HuksKeySize.HUKS_DES_KEY_SIZE_64
    };

    // Key usage.
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT
    };

    // Filling method.
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PADDING,
        value: huks.HuksKeyPadding.HUKS_PADDING_NONE
    };

    // packet mode.
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE,
        value: huks.HuksCipherMode.HUKS_MODE_CBC
    };

    // Group encryption offset vector, more secure.
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_IV,
        value: stringToUint8Array(IV)
    };

    return properties;
}

function encryptDES() {
    let huksInfo;
    let ret = true;
    let initOptions = {
        properties: getDesCBCEncryptProperties(),
        inData: new Uint8Array()
    }

    let updateOptions = {
        properties: getDesCBCEncryptProperties(),
        inData: stringToUint8Array(plainText.substring(0, 16))
    }

    let finishOptions = {
        properties: getDesCBCEncryptProperties(),
        inData: stringToUint8Array(plainText.substring(16, 32))
    }

    huks.initSession(DES_CBC_64_KEY_ALIAS, initOptions, (initErr, initData) => {
        if (initErr) {
            huksInfo = 'encryptDES initSession return code:' + initErr.code + ' ： ' + initErr.message;
            ret = false;
            huks.abortSession(initData.handle, initOptions, (abortErr, abortData) => {
                if (abortErr) {
                    huksInfo = 'encryptDES init abortSession return code:' + abortErr.code + ' ： ' + abortErr.message;
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
            huksInfo = 'encryptDES updateSession return code:' + updateErr.code + ' ： ' + updateErr.message;
            ret = false;
            huks.abortSession(handle, updateOptions, (abortErr, abortData) => {
                if (abortErr) {
                    huksInfo = 'encryptDES update abortSession return code:' + abortErr.code + ' ： ' + abortErr.message;
                }
            });
        } else {
            // Encrypted message reception
            cipherText = uint8ArrayToString(updateData.outData);
            huksInfo = cipherText
        }
    });
    if (!ret) {
        return huksInfo;
    }

    huks.finishSession(handle, finishOptions, (finishErr, finishData) => {
        if (finishErr) {
            ret = false;
            huksInfo = 'encryptDES finishSession return code:' + finishErr.code + ' ： ' + finishErr.message;
            huks.abortSession(handle, finishOptions, (abortErr, abortData) => {
                if (abortErr) {
                    huksInfo =
                        'encryptDES finish  abortSession return code:' + abortErr.code + ' ： ' + abortErr.message;
                }
            });
        } else {
            // Encrypted message reception
            cipherText = cipherText + uint8ArrayToString(finishData.outData);
            huksInfo = cipherText
        }
    });

    return huksInfo;
}
// [EndExclude des_decrypt]
function stringToUint8Array(str) {
    let arr = [];
    for (let i = 0, j = str.length; i < j; ++i) {
        arr.push(str.charCodeAt(i));
    }

    return new Uint8Array(arr);
}

function uint8ArrayToString(fileData) {
    let dataString = '';
    for (let i = 0; i < fileData.length; i++) {
        dataString += String.fromCharCode(fileData[i]);
    }

    return dataString;
}
// [End des_encrypt]

function GetDesCBCDecryptProperties() {
    let properties = new Array();
    let index = 0;
    // algorithm
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
        value: huks.HuksKeyAlg.HUKS_ALG_DES
    };
    // key length
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
        value: huks.HuksKeySize.HUKS_DES_KEY_SIZE_64
    };
    // Key usage
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT
    };
    // Filling method
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_PADDING,
        value: huks.HuksKeyPadding.HUKS_PADDING_NONE
    };
    // packet mode
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE,
        value: huks.HuksCipherMode.HUKS_MODE_CBC
    };
    // Group encryption offset vector, more secure
    properties[index++] = {
        tag: huks.HuksTag.HUKS_TAG_IV,
        value: stringToUint8Array(IV)
    };
    return properties;
}

function decryptDES() {
    let huksInfo;
    let ret = true;
    let outPlainText;
    let initOptions = {
        properties: GetDesCBCDecryptProperties(),
        inData: new Uint8Array()
    }
    let updateOptions = {
        properties: GetDesCBCDecryptProperties(),
        inData: stringToUint8Array(cipherText.substring(0, 16))
    }

    let finishOptions = {
        properties: GetDesCBCDecryptProperties(),
        inData: stringToUint8Array(cipherText.substring(16, 32))
    }

    huks.initSession(DES_CBC_64_KEY_ALIAS, initOptions, (initErr, initData) => {
        if (initErr) {
            ret = false;
            huksInfo = 'decryptDES initSession return code:' + initErr.code + ' ： ' + initErr.message;
            huks.abortSession(initData.handle, initOptions, (abortErr, abortData) => {
                if (abortErr) {
                    huksInfo =
                        'decryptDES initSession abortSession return code:' + abortErr.code + ' ： ' + abortErr.message;
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
            ret = false;
            huksInfo = 'decryptDES updateSession return code:' + updateErr.code + ' ： ' + updateErr.message;
            huks.abortSession(handle, updateOptions, (abortErr, abortData) => {
                if (abortErr) {
                    huksInfo = 'decryptDES update abortSession return code:' + abortErr.code + ' ： ' + abortErr.message;
                }
            });
        } else {
            // Clear text reception
            outPlainText = uint8ArrayToString(updateData.outData);
            huksInfo = outPlainText;
        }
    });

    if (!ret) {
        return huksInfo;
    }

    huks.finishSession(handle, finishOptions, (finishErr, finishData) => {
        if (finishErr) {
            ret = false;
            huksInfo = 'decryptDES finishSession return code:' + finishErr.code + ' ： ' + finishErr.message;
            huks.abortSession(handle, finishOptions, (abortErr, abortData) => {
                if (abortErr) {
                    huksInfo = 'decryptDES abortSession return code:' + abortErr.code + ' ： ' + abortErr.message;
                }
            });
        } else {
            // Clear text reception
            outPlainText = outPlainText + uint8ArrayToString(finishData.outData);
            huksInfo = outPlainText;
        }
    });

    return huksInfo;
}

// [End des_decrypt]