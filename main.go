package main

import (
	"flag"
	"log"
	"os"
	"time"
)

type Args struct {
	timeout int
	size    int
	actors  int
}

func stress(args *Args) *[]float64 {
	s := make([]float64, args.size)
	return &s
}

func load(args *Args) {
	num := 0
	for {
		s := stress(args)
		if s == nil {
			return
		}
		log.Println("Loop: ", num)
		num += 1
	}
}

func main() {
	var timeout *int = flag.Int("timeout", 10, "seconds")
	var size *int = flag.Int("size", 1000000000, "buffer size")
	var actors *int = flag.Int("actors", 1, "actors")

	flag.Parse()
	log.Printf("begin timeout: %d, buffer size: %d, actors: %d", *timeout, *size, *actors)

	args := &Args{
		timeout: *timeout,
		size:    *size,
		actors:  *actors,
	}

	for i := 0; i < args.actors; i++ {
		go load(args)
	}

	t := time.NewTimer(time.Duration(*timeout) * time.Second)

	select {
	case <-t.C:
		log.Println("done")
		os.Exit(0)
	}
}
