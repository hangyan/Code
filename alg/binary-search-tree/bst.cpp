#include <cstdio>

struct Node {
	int key;
	Node *left,*right,*parent;
	Node(int k=0,Node *l = NULL, Node *r = NULL, Node *p = NULL)
		:key(k),left(l),right(r),parent(p) {}
};

//中序遍历二叉树
void inorder(Node *x)
{
	if (x == NULL)
		return;
	inorder(x->left);
	printf("%d ",x->key);
	inorder(x->right);
}

//递归查找元素,找到返回关键字的结点指针，没找到返回NULL
Node* searchRecursive(Node *x,int k)
{
	if (x == NULL || x->key == k)
		return x;
	if (k < x->key)
		return searchRecursive(x->left,k);
	else
		return searchRecursive(x->right,k);
}

//非递归查找元素,找到返回关键字的结点指针，没找到返回NULL
Node* search(Node *x,int k)
{
	while (x != NULL && k != x->key) {
		if (k < x->key)
			x = x->left;
		else
			x = x->right;
	}
	return x;
}

//查找最小关键字  
Node* searchMin(Node *x)
{
	if (x == NULL) return NULL;
	while (x->left != NULL) x = x->left;
	return x;
}

Node* searchMax(Node *x)
{
	if (x == NULL)
		return NULL;
	while (x->right != NULL)
		x = x->right;
	return x;
}

Node* searchSuccessor(Node *x)
{
	if (x == NULL) {
		return NULL;
	}
	
	if (x->right != NULL)
		return searchMin(x->right);

	Node *y = x->parent;
	while(y != NULL && x == y->right) {
		x = y,y=y->parent;
	}
	
	return y;
}


Node* searchPredecessor(Node* x)
{
	if (x == NULL) {
		return NULL;
	}
	if (x -> left != NULL) {
		return searchMax(x->left);
	}

	Node* y = x->parent;
	while(y != NULL && x == y->left) {
		x = y,y = y->parent;
	}
	
	return y;
}

	
void insertNode(Node **root,int key)
{
	Node *z = new Node(key,NULL,NULL,NULL);
	Node* x = *root,*y = NULL;
	while (x != NULL) {
		y = x;
		if (key == x->key)
			return;
		else if(key < x->key) {
			x = x->left;
		} else {
			x = x->right;
		}
	}
	
	z->parent = y;
	if (y == NULL) {
		*root = z;
	} else if (key < y->key) {
		y->left =z;
	} else {
		y->right =z;
	}
}


void deleteNode(Node **root,int key)
{
	Node *z  = search(*root,key);
	if (z == NULL) {
		return;
	}

	Node *y = (z->left == NULL || z->right ==NULL)? z : searchSuccessor(z);
	Ndoe *x = y->left != NULL? y->left : y->right;

	if (x != NULL) {
		x->parent = y->parent;
	}

	

	


int main()
{
	Node *bst = NULL;
	int a[] = {15,6,18,7,3,17,20,2,4,13,9};

	for (int i = 0; i < 11; i++) {
		insertNode(&bst,a[i]);
	};

	inorder(bst);
	printf("\n");

	printf("%d %d\n",searchSuccessor(bst)->key,searchPredecessor(bst)->key);


	for (int i = 0; i < 9; i++) {
		deleteNode(&bst,a[i]);
	}

	inorder(bst);
	printf("\n");

	return 0;
}
	
