//
// Created by JimiWills on 31/08/2022.
//

#include <cstdio>
#include "middleware.h"

class MyMiddleWare1 : public Middleware {
public:
    MyMiddleWare1(){}
    void Invoke(){
        printf("Hi from 1\n");
        Next();
        printf("Bye from 1\n");
    };
};

class MyMiddleWare2 : public Middleware {
public:
    MyMiddleWare2(){}
    void Invoke(){
        printf("Hi from 2\n");
        Next();
        printf("Bye from 2\n");
    };
};

class MyMiddleWare3 : public Middleware {
public:
    MyMiddleWare3(){}
    void Invoke(){
        printf("Hi from 3\n");
        Next();
        printf("Bye from 3\n");
    };
};

class MyHandler : public Handler {
public:
    MyHandler(){}
    void Invoke(){
        printf("Hi, bye - from handler\n");
    };
};

int main(int argc, char *argv[]){
    MyMiddleWare1 mm1;
    MyMiddleWare2 mm2;
    MyMiddleWare3 mm3;
    MyHandler handler;
    Controller c(handler);

    c.Add(mm1);
    c.Add(mm2);
    c.Add(mm3);
    c.Invoke();

    return 0;
};
