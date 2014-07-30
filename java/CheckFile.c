/*                                                                      
 *  File:   CheckFile.c                                             
 *  Author: Hang Yan                                                       
 *  Email:  yanhangyhy@gmail.com                                      
 *  Date:   04 May 2014                                               
 *  Desc:   
 */ 

#include <stdio.h>
#include "CheckFile.h"


JNIEXPORT void JNICALL Java_CheckFile_displayHelloWorld (JNIEnv * a , jobject b)
{
    printf("hello jni.\n");
    return;
}


