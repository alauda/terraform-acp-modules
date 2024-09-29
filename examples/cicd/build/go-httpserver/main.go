package main

import (
	"fmt"
	"net/http"
)

var (
	// currentVersion is the current version number, used to determine whether it is the expected version.
	// This value will be determined at compile time.
	currentVersion string
)

func main() {
	fmt.Println("Start listening on port 8080. version: ", currentVersion)
	http.HandleFunc("/", HelloServer)
	http.ListenAndServe(":8080", nil)
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, %s!\nversion: %s", r.URL.Path[1:], currentVersion)
}
