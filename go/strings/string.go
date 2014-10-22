package main

import (
	"bytes"
	"fmt"
	"io"
	"strconv"
	"strings"
	"unicode"
)

func SimplifyWhitespace(s string) string {
	var buffer bytes.Buffer
	skip := true
	for _, char := range s {
		if unicode.IsSpace(char) {
			if !skip {
				buffer.WriteRune(' ')
				skip = true
			}
		} else {
			buffer.WriteRune(char)
			skip = false
		}
	}

	s = buffer.String()
	if skip && len(s) > 0 {
		s = s[:len(s)-1]
	}
	return s

}

func IsHexDigit(char rune) bool {
	return unicode.Is(unicode.ASCII_Hex_Digit, char)
}

func main() {
	names := "Niccolò•Noël•Geoffrey•Amélie••Turlough•José"
	fmt.Print("|")
	for _, name := range strings.Split(names, "•") {
		fmt.Printf("%s|", name)
	}

	fmt.Println()

	for _, record := range []string{"László Lajtha*1892*1963", "Édouard Lalo\t1823\t1892", "José Ángel Lamas|1775|1814"} {
		fmt.Println(strings.FieldsFunc(record, func(char rune) bool {
			switch char {
			case '\t', '*', '|':
				return true
			}
			return false
		}))
	}
	fmt.Println(SimplifyWhitespace(" hehe hehe        hehe  "))

	asciiOnly := func(char rune) rune {
		if char > 127 {
			return '?'
		}
		return char
	}
	fmt.Println(strings.Map(asciiOnly, "érôme Österreich"))

	reader := strings.NewReader("Café")
	for {
		char, size, err := reader.ReadRune()
		if err != nil {
			if err == io.EOF {
				break
			}
			panic(err)
		}
		fmt.Printf("%U '%c' %d: % X\n", char, char, size, []byte(string(char)))
	}

	for _, truth := range []string{"1", "t", "TRUE", "false", "F", "0", "5"} {
		if b, err := strconv.ParseBool(truth); err != nil {
			fmt.Printf("\n{%v} ", err)
		} else {
			fmt.Print(b, "")
		}
	}

	fmt.Println(IsHexDigit('8'), IsHexDigit('x'), IsHexDigit('X'),
		IsHexDigit('b'), IsHexDigit('B'))
}
