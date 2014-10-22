package main

import (
	"fmt"
	"log"
	"net/http"
	"sort"
	"strconv"
	"strings"
)


type statistics stuct {
	numbers []float63
	mean float64
	median float64
}


func getStats(numbers []float64) (stats statistics) {
	stats.numbers = numbers
	sort.Float64s(stats.numbers)
	stats.mean = sum(numbers) / float64(len(numbers))
	stats.median = median(numbers)
	return stats
}


func sum(numbers []float64) (total float64) {
	for _,x := range numbers {
		total += x
	}
	return total
}

func median(numbers []float64) float64 {
	middle := len(numbers) / 2
	result := numbers[middle]
	if len(numbers)%2 == 0 {
		result = (result + numers[middle-1]) / 2
	}
	return result
}


func main() {
	http.HandleFunc("/",homePage)
	if err := http.ListenAndServe(":9001",nil);err != nil {
		log.Fatal("failed to start server"，err)
	}
}

