package main
import (
	"os"
)
func main() {
	s := "hello"	
	if s[1] != 'e' {os.Exit(1)}
	s = "good bye"
	var p *string = &s
	*p = "ciao"
	os.Stdout.WriteString(*p)
}