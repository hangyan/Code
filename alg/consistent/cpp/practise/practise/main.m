//
//  main.m
//  practise
//
//  Created by Hang Yan on 15/3/2.
//  Copyright (c) 2015年 Hang Yan. All rights reserved.
//


#import <Foundation/Foundation.h>

/*
int main(int argc, const char * argv[]){
    int i,count;
    NSLog(@"please enter the number you want to list :");
    scanf("%i",&count);
    NSLog(@"The number  from 1 to %d is :",count);
    for (i=1; i<=count; i++) {
        NSLog(@"%d \n",i);
    }
    return 0;
}
*/


/*
int main(int argc, const char * argv[]){
    const char *words[4]= {"abc","abcd","abcde","abcdef"};
    int i;
    int wordcount=4;
    for (i=0; i< wordcount; i++) {
        NSLog(@"%s is %d characters long", words[i], strlen(words[i]));
        
    }
    return 0;
}
*/


/*
int main(int argc, const char *argv[]){
    char *wordfile = fopen("/tmp/word.txt", "r");
    char word[100];
    while (fgets(word, 100, wordfile)) {
        word[strlen(word)-1] = '\0';
        NSLog(@"%s is %d characters long",word,strlen(word));
    }
    
    fclose(wordfile);
    return 0;
}
*/

















