package main

import (
	"fmt"
)

type Optioner interface {
	Name() string
	IsValid() bool
}

type OptionCommon struct {
	ShortName string "short option name"
	LongName  string "long option name"
}

type IntOption struct {
}

func main() {

}
