# FAQ:静态共享包HAR如何引用另一个HAR包中的so文件
# [Start importLibnativeSub]
target_link_directories(entry PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/)
target_link_libraries(entry PUBLIC libace_napi.z.so libc++.a libnativeSub.so)
# [End importLibnativeSub]