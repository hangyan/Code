package main

import (
	"bytes"
	"encoding/json"
	"fmt"

	"math"
	"strings"
)

func BoundedInt(minimum, value, maximum int) int {
	switch {
	case value < minimum:
		return minimum
	case value > maximum:
		return maximum
	}

	return value
}

// type

func jsonObjectAsString(jsonObject map[string]interface{}) string {
	var buffer bytes.Buffer
	buffer.WriteString("{")
	comma := ""

	for key, value := range jsonObject {
		buffer.WriteString(comma)
		switch value := value.(type) {
		case nil:
			fmt.Fprintf(&buffer, "%q: null", key)
		case bool:
			fmt.Fprintf(&buffer, "%q: %t", key, value)
		case float64:
			fmt.Fprintf(&buffer, "%q: %f", key, value)
		case string:
			fmt.Fprintf(&buffer, "%q: %q", key, value)
		case []interface{}:
			fmt.Fprintf(&buffer, "%q: [", key)
			innerComma := ""
			for _, s := range value {
				if s, ok := s.(string); ok {
					fmt.Fprintf(&buffer, "%s%q", innerComma, s)
					innerComma = ", "
				}
			}
			buffer.WriteString("]")
		}

		comma = ", "
	}
	buffer.WriteString("}")
	return buffer.String()

}

// json struct
type State struct {
	Name     string
	Senators []string
	Water    float64
	Area     int
}

func (state State) String() string {
	var senators []string
	for _, senator := range state.Senators {
		senators = append(senators, fmt.Sprintf("%q", senator))
	}

	return fmt.Sprintf(
		`{"name": %q, "area": %d, "water": %f, "senators": [%s]}`,
		state.Name, state.Area, state.Water, strings.Join(senators, ", "))

}

// go concurrent

func createCounter(start int) chan int {

	next := make(chan int)
	go func(i int) {
		for {
			next <- i
			i++
		}

	}(start)

	return next
}

//exceptions
func ConvertInt64ToInt(x int64) int {
	if math.MinInt32 <= x && x <= math.MaxInt32 {
		return int(x)
	}
	panic(fmt.Sprintf("%d is out of the int32 range", x))
}

func IntFromInt64(x int64) (i int, err error) {
	defer func() {
		if e := recover(); e != nil {
			err = fmt.Errorf("%v", e)
		}
	}()

	i = ConvertInt64ToInt(x)

	return i, nil
}

func main() {
	MA := []byte(`{"name": "Massachusetts", "area": 27336, "water": 25.7, "senators": ["John Kerry", "Scott Brown"]}`)
	var object interface{}
	if err := json.Unmarshal(MA, &object); err != nil {
		fmt.Println(err)
	} else {
		jsonObject := object.(map[string]interface{})
		fmt.Println(jsonObjectAsString(jsonObject))
	}

	// konw the json struture
	var state State
	if err := json.Unmarshal(MA, &state); err != nil {
		fmt.Println(err)
	}

	fmt.Println(state)

	// channels

	counterA := createCounter(2)
	counterB := createCounter(102)
	for i := 0; i < 5; i++ {
		a := <-counterA
		fmt.Printf("(A->%d,B-%d)", a, <-counterB)
	}
	fmt.Println()

	// select
	channels := make([]chan bool, 6)
	for i := range channels {
		channels[i] = make(chan bool)
	}

	go func() {
		for {
			channels[rand.Intn(6)] <- true
		}
	}()

	for i := 0; i < 36; i++ {
		var x int
		select {
		case <-channels[0]:
			x = 1
		case <-channels[1]:
			x = 2
		case <-channels[2]:
			x = 3
		case <-channels[3]:
			x = 4
		case <-channels[4]:
			x = 5
		case <-channels[5]:
			x = 6
		}
		fmt.Printf("%d ", x)
	}
	fmt.Println()

}
