package main

import (
	"fmt"
	"strings"

	"unicode/utf8"
)

//variadic functions
func MinimumInt1(first int, rest ...int) int {
	for _, x := range rest {
		if x < first {
			first = x
		}
	}
	return first
}

// closure
func MakeAddSuffix(suffix string) func(string) string {
	return func(name string) string {
		if !strings.HasSuffix(name, suffix) {
			return name + suffix
		}
		return name
	}
}

// recursive

func Fibonacci(n int) int {
	if n < 2 {
		return n
	}
	return Fibonacci(n-1) + Fibonacci(n-2)
}

func HofstadterFemale(n int) int {
	if n <= 0 {
		return 1
	}

	return n - HofstadterMale(HofstadterFemale(n-1))
}

func HofstadterMale(n int) int {
	if n <= 0 {
		return 0
	}
	return n - HofstadterFemale(HofstadterMale(n-1))
}

//generic
func IntIndexSlicer(ints []int, x int) int {
	return IndexSlicer(IntSlice(ints), x)
}

type Slicer interface {
	EqualTo(i int, x interface{}) bool
	Len() int
}

type IntSlice []int

func (slice IntSlice) EqualTo(i int, x interface{}) bool {
	return slice[i] == x.(int)
}

func (slice IntSlice) Len() int {
	return len(slice)
}

func IndexSlicer(slice Slicer, x interface{}) int {
	for i := 0; i < slice.Len(); i++ {
		if slice.EqualTo(i, x) {
			return i
		}
	}
	return -1
}

// higher order function
func SliceIndex(limit int, predicate func(i int) bool) int {
	for i := 0; i < limit; i++ {
		if predicate(i) {
			return i
		}
	}
	return -1
}

// memoizing pure functions
type memoizeFunction func(int, ...int) interface{}

var Fibonacci memoizeFunction

func init() {
	Fibonacci = Memoize(func(x int, xs ...int) interface{} {
		if x < 2 {
			return x
		}
		return Fibonacci(x-1).(int) + Fibonacci(x-2).(int)
	})
}

func main() {
	fmt.Println(MinimumInt1(5, 4), MinimumInt1(7, 3, -2, 4, 0, -8, -5))

	addZip := MakeAddSuffix(".zip")
	addTgz := MakeAddSuffix(".tar.gz")

	fmt.Println(addTgz("filename"), addZip("filename"), addZip("gobook.zip"))

	// recursive
	for n := 0; n < 20; n++ {
		fmt.Print(Fibonacci(n), " ")
	}
	fmt.Println()

	females := make([]int, 20)
	males := make([]int, len(females))
	for n := range females {
		females[n] = HofstadterFemale(n)
		males[n] = HofstadterMale(n)
	}
	fmt.Println("F", females)
	fmt.Println("M", males)

}
