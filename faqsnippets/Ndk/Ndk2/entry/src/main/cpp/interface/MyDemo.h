#ifndef RECCOBJECT_MYDEMO_H
#define RECCOBJECT_MYDEMO_H
#include <string>
class MyDemo {
public:
    MyDemo(std::string m_name) {
        this->name = m_name;
    };
    std::string name;
};
#endif //RECCOBJECT_MYDEMO_H
