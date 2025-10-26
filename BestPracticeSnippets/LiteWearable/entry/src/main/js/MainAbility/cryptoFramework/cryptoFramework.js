// [Start do_md]
import cryptoFramework from '@ohos.security.cryptoFramework';
// [StartExclude do_md]
export default {
    data: {
        title: ""
    },
    onInit() {
        this.title = 'Hello World';
    }
};
// [EndExclude do_md]
function stringToUint8Array(str) {
    let arr = [];
    for (let i = 0, j = str.length; i < j; ++i) {
        arr.push(str.charCodeAt(i));
    }
    let tmpUint8Array = new Uint8Array(arr);
    return tmpUint8Array;
}

function doMd() {
    let mdAlgName = 'SHA256'; // Abstract algorithm name.
    let message = 'mdTestMessage'; // The data to be summarized.
    let handle;
    let mdResult;
    let mdLen;
    // Specify the digest algorithm SHA256 and generate an instance of the digest operation.
    try {
        handle = cryptoFramework.createMd(mdAlgName);
    } catch (error) {
        console.error(`createMd error, code: ${error.code}, msg: ${error.message}`);
    }
    try {
        // When the data volume is small, only one update operation can be performed, and all the data can be sent in.
        // The interface does not impose any restrictions on the length of the input parameters.
        handle?.updateSync({ data: stringToUint8Array(message) });
    } catch (error) {
        console.error(`updateSync error, code:+${error.code}, msg: ${error.message}`);
    }
    // Obtain the summary calculation results.
    try {
        mdResult = handle?.digest();
    } catch (error) {
        console.error(`digest error, code: ${error.code}, msg: ${error.message}`);
    }
    console.info('Md result:' + mdResult?.data);
    // Obtain the length of the summary calculation, with the unit being bytes.
    try {
        mdLen = handle?.getMdLength();
    } catch (error) {
        console.error(`getMdLength error, code: ${error.code}, msg: ${error.message}`);
    }
    console.info(`md len: ${mdLen}`);
}
// [End do_md]
// [Start do_rand]
function doRand() {
    let rand;
    let ret = true;
    let randData
    // Example of generating random numbers operation.
    try {
        rand = cryptoFramework.createRandom();
    } catch (error) {
        ret = false;
        console.error(`createRandom error, code:+${error.code}, msg: ${error.message}`);
    }
    let len = 24; // Generate a 24-byte random number.
    // (Optional) Call Random.setSeed to set the seed for the random number generation pool.
    let seed = new Uint8Array([1, 2, 3]);
    try {
        rand?.setSeed({ data: seed });
    } catch (error) {
        ret = false;
        console.error(`setSeed error, code:+${error.code}, msg: ${error.message}`);
    }

    try {
        // Generate secure random numbers.
        randData = rand?.generateRandomSync(len);
    } catch (error) {
        ret = false;
        console.error(`generateRandomSync error, code:+${error.code}, msg: ${error.message}`);
    }
    if (ret) {
        return randData?.data;
    } else {
        console.error(`doRand error`);
        return 'doRand error';
    }
}
// [End do_rand]