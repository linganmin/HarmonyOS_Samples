// handler.js is a demo for handler function.
let myHandler = function (event, context, callback, logger) {
    let res = new context.HTTPResponse({ "sort": "id" }, {
        "res-type": "simple example",
        "faas-content-type": "json"
    }, "application/json", "200");

    // send debug log
    logger.debug("this is message of debug log");

    // send info log
    logger.info("this is message of info log");

    // send error log
    logger.error("Test error log");

    // send response
    callback(res);
};

module.exports.myHandler = myHandler;
