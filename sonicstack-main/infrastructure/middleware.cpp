#include <stdio.h>

#include "middleware.h";

Middleware::Middleware()
{
    hasNext = false;
    rindex = 0;
};
void Middleware::Append(Middleware &last){
    rindex++;
    if(hasNext){
        next->Append(last);
    }
    else {
        this->SetNext(last);
    }
}
void Middleware::InsertBeforeLast(Middleware &penultimate){
    bool isBeforePenultimate = rindex > 1;
    rindex++;
    if(isBeforePenultimate){
        next->InsertBeforeLast(penultimate);
    }
    else {
        penultimate.Append(*next);
        this->SetNext(penultimate);
    }
}
void Middleware::Next(){
    if(hasNext){
        next->Invoke();
    }
}
bool Middleware::HasNext(){ return hasNext; }
void Middleware::SetNext(Middleware &next){
    this->next = &next;
    hasNext = true;
}

Handler::Handler(){}
void Handler::Next(){throw "Next is not implemented in Handler base.";}

Controller::Controller(Middleware &handler){
    Append(handler);
}
void Controller::Add(Middleware &middleware){
    InsertBeforeLast(middleware);
}

void Controller::Invoke(){
    printf("Hi from Controller\n");
    Next();
    printf("Bye from Controller\n");
}

