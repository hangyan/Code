#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <Stack>
#include <Queue>

using namespace std;
#define Element char
#define format "%c"

typedef struct Node {
  Element data;
  struct Node *lchild;
  struct Node *rchild;
} *Tree;

int index = 0;

void treeNodeConstructor(Tree &root,Element data[]) {
  Element e = data[index++];
  if (e == '#') {
	root = NULL;
  } else {
	  root = (Node*)malloc(sizeof(Node));
	  root->data = e;
	  treeNodeConstructor(root-lchild,data);
	  treeNodeConstructor(root-lchild,data);
  }
}



int main()
{
    //上图所示的二叉树先序遍历序列,其中用'#'表示结点无左子树或无右子树
  Element data[15] = { 'A','B','D','#','#','E','#','#','C','F','#','#','G','#','#'};
  Tree tree;
  treeNodeConstructor(tree,data);
  printf("Depth First Search Result:");
  depthFirstSearch(tree);
  printf("\n\nBreadth First Search Result:");
  breadthFirstSearch(tree);
  return 0;
}
  
