//
//  main.m
//  Bool Party
//
//  Created by Hang Yan on 15/3/2.
//  Copyright (c) 2015年 Hang Yan. All rights reserved.
//

#import <Foundation/Foundation.h>

BOOL areintsDifferent(int thing1,int thing2)
{
    if (thing1 == thing2) {
        return (NO);
    }else{
        return (YES);
    }
}

NSString *boolString (BOOL yesno)
{
    if (yesno == NO) {
        return (@"NO");
    }else{
        return (@"yes");
    }
}

int main(int argc ,const char * argv[]){
    bool areTheyDifferent;
    areTheyDifferent = areintsDifferent(5, 5);
    NSLog(@"are %d and %d different? %@",5,5,boolString(areTheyDifferent));
    
    areTheyDifferent = areintsDifferent(34, 22);
    NSLog(@"are %d and %d different? %@" , 34,22,boolString(areTheyDifferent));
    
    return (0);

}




/*
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
    }
    return 0;
}
*/