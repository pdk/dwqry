package main

import (
	"encoding/csv"
	"fmt"
	"io"
	"os"
)

func main() {

	r := csv.NewReader(os.Stdin)
	for {
		record, err := r.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			fmt.Printf("Failed to scan line: %s", err)
			os.Exit(1)
		}

		fmt.Printf("%s %s\n", record[0], record[2])
	}
}
