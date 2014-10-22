package main

import (
	"fmt"
	"sort"
	"strings"
)

// demonstrate custom type string function
type Product struct {
	name  string
	price float64
}

func (product Product) String() string {
	return fmt.Sprintf("%s (%.2f)", product.name, product.price)
}

// remove part from slice
func RemoveStringSliceCopy(slice []string, start, end int) []string {
	result := make([]string, len(slice)-(end-start))
	at := copy(result, slice[:start])
	copy(result[at:], slice[end:])
	return result

}

func RemoveStringSlice(slice []string, start, end int) []string {
	return append(slice[:start], slice[end:]...)
}

// string sort.
type FoldedStrings []string

func SortFolderStrings(slice []string) {
	sort.Sort(FoldedStrings(slice))
}

func (slice FoldedStrings) Len() int {
	return len(slice)
}

func (slice FoldedStrings) Less(i, j int) bool {
	return strings.ToLower(slice[i]) < strings.ToLower(slice[j])
}

func (slice FoldedStrings) Swap(i, j int) {
	slice[i], slice[j] = slice[j], slice[i]
}

// maps
type Point struct{ x, y, z int }

func (point Point) String() string {
	return fmt.Sprintf("(%d,%d,%d)", point.x, point.y, point.z)
}

func main() {
	products := []*Product{{"Spanner", 3.99}, {"Wrench", 2.49}, {"Screwdriver", 1.99}}
	fmt.Println(products)

	for _, product := range products {
		product.price += 0.50
	}
	fmt.Println(products)

	triangle := make(map[*Point]string, 3)

	triangle[&Point{89, 47, 27}] = "α"
	triangle[&Point{86, 65, 86}] = "β"
	triangle[&Point{7, 44, 45}] = "γ"
	fmt.Println(triangle)

}
