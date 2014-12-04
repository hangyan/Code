package org.yayu.design.memento;

import java.

public class FileWriterClient {


  public static void main(String[] args) {
	FileWriterCaretaker caretaker = new FileWriterCaretaker();

    FileWriterUtil fileWriter = new FileWriterUtil("data.txt");
    fileWriter.write("first set of data\n");
    System.out.println(fileWriter + "\n\n");

    caretaker.save(fileWriter);
    fileWriter.write("Second set of data\n");

    System.out.println(fileWriter + "\n\n");

	caretaker.undo(fileWriter);
	System.out.println(fileWriter + "\n\n");

	List a = new ArrayList();
	
	
  }

}
