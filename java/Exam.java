/**
 * This Examples was used to demonstrate the usage of DelayedQueue.
 */

package org.urbem.java.ds;

import java.util.*;


class Student implements Runnable,Delayed {
    private String name;
    private long submitTime;
    private long workTime;

    public Student(String name,long submitTime) {
        super();
        this.name = name;
        workTime = submitTime;
        

public class Exam 
{
    static final int STUDENT_SIZE = 45;
    public static void main(String[] args)  {
        Random r = new Random();
        DelayQueue<Student> students = new DelayQueue<Student>();
        ExecutorService exec = Excutors.newCachedThreadPool();
        for(int i = 0;i<STUDENT_SIZE;i++) {
            students.put(new Student("学生" + (i+1),3000+ r.nextInt(9000)));
        }
        students.put(new Student.EndExam(12000,exec));
        exec.execute(new Teacher(students,exec));
                
    }

}
