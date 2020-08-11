package main

func preorderTraversal(root *TreeNode)  {
    if root==nil{
        return
    }
    // 先访问根再访问左右
    fmt.Println(root.Val)
    preorderTraversal(root.Right)
}