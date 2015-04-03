/*
  Prim最小生成树算法C语言实现
*/

#include <stdio.h>
#define MAX_WEIGHT 0x7FFFFFFF


/*
                 8         7
             b ------- c ------- d 
           / |       /  \       |  \  9
      4   /  |   2  /    \      |   \
         /   |     /      \ 4   |    \
        a 11 |    i        \    | 14  \
         \   | 7 / \        \   |      e
      8   \  |  /   \ 6      \  |    /
	       \ | /     \        \ |  /  10
             h ------ g -------- f 
                  1        2
*/


int prim(int n, int adjMatrix[][n], const char vertex[]);


int main()
{
  // 节点及其个数
  const char vertex[] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h','i'};
  const int n = sizeof(vertex) / sizeof(char);

  int adjMatrix[9][9] = {
	{MAX_WEIGHT, 4, MAX_WEIGHT, MAX_WEIGHT,MAX_WEIGHT, MAX_WEIGHT, MAX_WEIGHT, 8, MAX_WEIGHT},	  
	{4, MAX_WEIGHT, 8, MAX_WEIGHT,MAX_WEIGHT, MAX_WEIGHT, MAX_WEIGHT, 11, MAX_WEIGHT},	
	{MAX_WEIGHT, 8, MAX_WEIGHT, 7,MAX_WEIGHT, 4, MAX_WEIGHT, MAX_WEIGHT, 2},	
	{MAX_WEIGHT, MAX_WEIGHT, 7, MAX_WEIGHT,9, 14, MAX_WEIGHT, MAX_WEIGHT, MAX_WEIGHT},	
	{MAX_WEIGHT, MAX_WEIGHT, MAX_WEIGHT, 9,MAX_WEIGHT, 10, MAX_WEIGHT, MAX_WEIGHT, MAX_WEIGHT},	
	{MAX_WEIGHT, MAX_WEIGHT, 4, 14,10, MAX_WEIGHT, 2, MAX_WEIGHT, MAX_WEIGHT},	
	{MAX_WEIGHT, MAX_WEIGHT, MAX_WEIGHT, MAX_WEIGHT,MAX_WEIGHT, 2, MAX_WEIGHT, 1, 6},	
	{8, 11, MAX_WEIGHT, MAX_WEIGHT,MAX_WEIGHT, MAX_WEIGHT, 1, MAX_WEIGHT, 7},	
	{MAX_WEIGHT, MAX_WEIGHT, 2, MAX_WEIGHT,MAX_WEIGHT, MAX_WEIGHT, 6, 7, MAX_WEIGHT}
  };

  int sum_weight = prim(n, adjMatrix, vertex);
  printf("the min sum of weight is %d\n", sum_weight);

  return 0;
}


int prim(int n, int adjMatrix[][n], const char vertex[])
{
  int sum_weight = 0;
  int low_cost[n];
  int start_vertex[n];
  int min_weight;
  int min_id;

  int i,j;

  // 第一个顶点加入生成树
  start_vertex[0] = -1;

  // 从顶点0出发的所有边的权值
  for (i = 1; i < n; i++) {
	start_vertex[i] = 0;
	low_cost[i] = adjMatrix[0][i];
  }

  for (i = 1; i < n; i++) {
	
	min_weight = MAX_WEIGHT;
	min_id = 0;

	// 寻找权值最小的顶点
	for (j = 1; j <n; j++) {
	  if (low_cost[j] < min_weight && low_cost[j] != -1) {
		min_weight = low_cost[j];
		min_id = j;
	  }
		
	}

	sum_weight += min_weight;
	// 标记顶点j已经加入生成树中.
	low_cost[min_id] = -1;

	printf("%c ---- %c : %d \n", vertex[(start_vertex[min_id])], vertex[min_id], min_weight);

	// 更新当前节点min_id到其他节点权值，而原来的low_cost[]保存了之前顶点的最小权值,
	for (j = 1; j < n; j++) {
	  if (adjMatrix[min_id][j] < low_cost[j]) {
		low_cost[j] = adjMatrix[min_id][j];
		start_vertex[j] = min_id;
		
	  }
	}
	
  }
  return sum_weight;
  
  
}


