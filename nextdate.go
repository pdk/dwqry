package main

import (
	"fmt"
	"os"
	"time"
)

func main() {

	if len(os.Args) < 2 {
		fmt.Printf("date in format 2006-01-02 required\n")
		os.Exit(1)
	}

	d, err := time.Parse("2006-01-02", os.Args[1])
	if err != nil {
		fmt.Printf("%s\n", err)
		os.Exit(2)
	}

	d = d.AddDate(0, 0, 1)

	fmt.Printf("%s\n", d.Format("2006-01-02"))
}
