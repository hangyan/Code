package main

import (
	"fmt"
	"strings"
	"unicode"
)

type RuneForRuneFunc func(rune) rune

var removePunctuation RuneForRuneFunc

func processPhrases(phrases []string, function RuneForRuneFunc) {

	for _, phrase := range phrases {
		fmt.Println(strings.Map(function, phrase))
	}
}

// methods

type Count int

func (count *Count) Increment() {
	*count++
}

func (count *Count) Decrement() {
	*count--
}

func (count Count) IsZero() bool {
	return count == 0

}

// custome type methods 2
type Part struct {
	Id   int
	Name string
}

func (part *Part) LowerCase() {
	part.Name = strings.ToLower(part.Name)
}

func (part *Part) UpperCase() {
	part.Name = strings.ToUpper(part.Name)
}

func (part Part) String() string {
	return fmt.Sprintf("<<%d %q>>", part.Id, part.Name)
}

func (part Part) HasPrefix(prefix string) bool {
	return strings.HasPrefix(part.Name, prefix)
}

type Item struct {
	id       string
	price    float64
	quantity int
}

func (item *Item) Cost() float64 {
	return item.price * float64(item.quantity)
}

type SpecialItem struct {
	Item
	catalogId int
}

type LuxuryItem struct {
	Item
	markup float64
}

func (item *LuxuryItem) Cost() float64 {
	return item.Item.Cost() * item.markup
}

type Place struct {
	latitude, longitude float64
	Name                string
}

type LowerCaser interface {
	LowerCase()
}

type UpperCaser interface {
	UpperCase()
}

type LowerUpperCaser interface {
	LowerCaser
	UpperCaser
}

type FixCaser interface {
	FixCase()
}

type ChangeCaser interface {
	LowerUpperCaser
	FixCaser
}

func fixCase(s string) string {

	var chars []rune
	upper := true
	for _, char := range s {

		if upper {
			char = unicode.ToUpper(char)
		} else {
			char = unicode.ToLower(char)
		}
		chars = append(chars, char)
		upper = unicode.IsSpace(char) || unicode.Is(unicode.Hyphen, char)
	}
	return string(chars)
}

func (part *Part) FixCase() {
	part.Name = fixCase(part.Name)
}

func main() {

	phrases := []string{"Day;dusk,and night", "All day long"}
	removePunctuation = func(char rune) rune {
		if unicode.Is(unicode.Terminal_Punctuation, char) {
			return -1
		}
		return char
	}
	processPhrases(phrases, removePunctuation)

	// methods
	var count Count
	i := int(count)
	count.Increment()
	j := int(count)
	count.Decrement()
	k := int(count)
	fmt.Println(count, i, j, k, count.IsZero())

	part := Part{5, "wrench"}
	part.UpperCase()
	part.Id += 11
	fmt.Println(part, part.HasPrefix("w"))

	special := SpecialItem{Item{"Green", 3, 5}, 207}
	fmt.Println(special.id, special.price, special.quantity)
	fmt.Println(special.Cost())
}
