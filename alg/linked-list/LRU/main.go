package main

import "fmt"

type Node struct {
	Next  *Node
	Value interface{}
}

type Memory struct {
	Head *Node
	Max  int32
}

func (m *Memory) Insert(newNode interface{}) {
	if m.Head == nil {
		m.Head = &Node{
			Next:  nil,
			Value: newNode,
		}
		return
	}

	var pre *Node
	current := m.Head
	var i int32 = 1

	n := &Node{
		Next:  m.Head,
		Value: newNode,
	}

	for {
		if current.Value == newNode {
			if pre != nil {
				pre.Next = current.Next
				m.Head = n
			}
		}

		if current.Next == nil {
			if i >= m.Max {
				pre.Next = nil
				m.Head = n
			} else {
				m.Head = n
			}
			break
		}

		pre = current
		current = current.Next
		i++

	}
}
func main() {
	m := &Memory{
		Max: 10,
	}
	for i := 0; i <= 11; i++ {
		v := i
		m.Insert(&v)
		fmt.Printf("==========\n")
		fmt.Printf("head is %+v\n", m.Head)
		fmt.Printf("head value is %v\n", *m.Head.Value.(*int))
		fmt.Printf("==========\n")
	}
}
