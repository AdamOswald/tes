//
// Created by JimiWills on 31/08/2022.
//

#ifndef SONICSTACK_MIDDLEWARE_H
#define SONICSTACK_MIDDLEWARE_H


class Middleware {
public:
    Middleware();
    void Append(Middleware &last);
    void InsertBeforeLast(Middleware &penultimate);
    void Next();
    bool HasNext();
    virtual void Invoke() = 0;
private:
    Middleware *next;
    int rindex;
    bool hasNext;
    void SetNext(Middleware &next);
};

class Handler : public Middleware {
public:
    Handler();
    void Next();
    virtual void Invoke() = 0;
};

class Controller : public Middleware {
public:
    Controller(Middleware &handler);
    void Add(Middleware &middleware);
    void Invoke();
};

#endif //SONICSTACK_MIDDLEWARE_H
